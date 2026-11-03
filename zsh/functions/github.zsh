gh-repo-defaults() {
  if [[ $# -ne 1 ]]; then
    echo "usage: gh-repo-defaults owner/repo" >&2
    return 1
  fi

  local repo=$1 visibility

  visibility=$(gh api -X PATCH "repos/${repo}" \
    -F allow_squash_merge=true \
    -F allow_merge_commit=false \
    -F allow_rebase_merge=false \
    -F allow_update_branch=true \
    -F delete_branch_on_merge=true \
    -f squash_merge_commit_title=PR_TITLE \
    -f squash_merge_commit_message=PR_BODY \
    -F has_wiki=false \
    -F has_projects=false \
    --jq .visibility) || return
  gh api --silent -X PUT "repos/${repo}/automated-security-fixes" || return
  gh api --silent -X PUT "repos/${repo}/actions/permissions/workflow" \
    -f default_workflow_permissions=read \
    -F can_approve_pull_request_reviews=false || return

  # private repos on the free plan get no rulesets (so auto-merge has no checks
  # to wait for), secret scanning or vulnerability reporting
  [[ $visibility == public ]] || return 0

  gh api --silent -X PATCH "repos/${repo}" \
    -F allow_auto_merge=true \
    -f 'security_and_analysis[secret_scanning][status]=enabled' \
    -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled' || return
  gh api --silent -X PUT "repos/${repo}/private-vulnerability-reporting" || return

  if [[ -n $(gh api "repos/${repo}/rulesets" --jq '.[] | select(.name == "main") | .id') ]]; then
    echo "${repo} already has a main ruleset; left as is" >&2
    return 0
  fi

  gh api --silent -X POST "repos/${repo}/rulesets" --input - <<'EOF'
{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}},
  "bypass_actors": [],
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": false,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": false,
      "allowed_merge_methods": ["squash"]
    }}
  ]
}
EOF
}

# with no checks, lists the ones the latest PR ran, since check names only
# exist once CI has run
gh-require-checks() {
  if [[ $# -lt 1 ]]; then
    echo "usage: gh-require-checks owner/repo [check ...]" >&2
    return 1
  fi

  local repo=$1
  shift

  if [[ $# -eq 0 ]]; then
    local pr
    pr=$(gh pr list -R "$repo" --state all --limit 1 --json number --jq '.[0].number') || return
    if [[ -z $pr ]]; then
      echo "${repo} has no PRs yet" >&2
      return 1
    fi
    gh pr view "$pr" -R "$repo" --json statusCheckRollup --jq '.statusCheckRollup[] | .name // .context' | sort -u
    return
  fi

  local id
  id=$(gh api "repos/${repo}/rulesets" --jq '.[] | select(.name == "main") | .id') || return
  if [[ -z $id ]]; then
    echo "${repo} has no main ruleset; run gh-repo-defaults first" >&2
    return 1
  fi

  CHECKS=$(printf '%s\n' "$@") gh api "repos/${repo}/rulesets/${id}" --jq '{
    name, target, enforcement, conditions, bypass_actors,
    rules: ([.rules[] | select(.type != "required_status_checks")] + [
      {type: "required_status_checks", parameters: {
        strict_required_status_checks_policy: true,
        required_status_checks: ($ENV.CHECKS | split("\n") | map({context: .}))
      }}
    ])
  }' | gh api --silent -X PUT "repos/${repo}/rulesets/${id}" --input -
}
