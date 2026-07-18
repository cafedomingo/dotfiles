#!/bin/sh
input=$(cat)

# single jq pass: spawning one process per field adds up on every render
eval "$(printf '%s' "$input" | jq -r '@sh "
cwd=\(.workspace.current_dir // .cwd)
model=\(.model.display_name // "")
remaining=\(.context_window.remaining_percentage // "")
effort=\(.effort.level // "")
cost=\(.cost.total_cost_usd // "")
added=\(.cost.total_lines_added // 0)
removed=\(.cost.total_lines_removed // 0)
quota=\(.rate_limits.five_hour.used_percentage // "")
transcript=\(.transcript_path // "")
"')"

# colors
R='\033[0m'; DIM='\033[2m'
GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'

# pick a color for a percentage, given whether high is good or bad
color_pct() { # $1=value $2=good|bad (meaning of a high value)
  v=$(printf '%.0f' "$1" 2>/dev/null) || v=0
  if [ "$2" = good ]; then
    [ "$v" -ge 50 ] && printf '%s' "$GREEN" && return
    [ "$v" -ge 20 ] && printf '%s' "$YELLOW" && return
    printf '%s' "$RED"
  else
    [ "$v" -ge 80 ] && printf '%s' "$RED" && return
    [ "$v" -ge 50 ] && printf '%s' "$YELLOW" && return
    printf '%s' "$GREEN"
  fi
}

# ISO8601 -> epoch, GNU date then BSD date.
# -u on both: transcript timestamps are UTC, and BSD date would otherwise read
# them as local time and skew the result by the UTC offset.
iso_epoch() {
  date -u -d "$1" +%s 2>/dev/null || date -j -u -f '%Y-%m-%dT%H:%M:%S' "${1%.*}" +%s 2>/dev/null
}

# user@host
user=$(whoami)
host=$(hostname -s)

# directory: truncate long paths with ellipsis, similar to starship truncation_length=10
dir=$(printf '%s' "$cwd" | sed "s|$HOME|~|")
# count path components
components=$(printf '%s' "$dir" | tr -cd '/' | wc -c | tr -d ' ')
if [ "$components" -gt 10 ]; then
  dir="…/$(printf '%s' "$dir" | rev | cut -d'/' -f1-10 | rev)"
fi

# git branch, with * when the tree is dirty
# --no-optional-locks so the statusline never contends with a running git command
branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | head -1)" ]; then
    branch="${YELLOW}${branch}*${R}"
  fi
fi

# context remaining
ctx=""
if [ -n "$remaining" ]; then
  ctx=" $(color_pct "$remaining" good)ctx:${remaining%.*}%${R}"
fi

# prompt cache countdown: a cache hit is far cheaper, so knowing the window is
# about to lapse is actionable. TTL is inferred from which ephemeral bucket the
# last cache write landed in.
cache=""
if [ -n "$transcript" ] && [ -r "$transcript" ]; then
  cache_info=$(tail -n 100 "$transcript" 2>/dev/null | jq -rs '
    [.[] | select(.type=="assistant" and .message.usage.cache_creation != null)] | last
    | if . == null then empty
      else "\(.timestamp) \(if .message.usage.cache_creation.ephemeral_1h_input_tokens > 0 then 3600 else 300 end)"
      end' 2>/dev/null)
  if [ -n "$cache_info" ]; then
    written=$(iso_epoch "${cache_info% *}")
    ttl=${cache_info#* }
    if [ -n "$written" ]; then
      left=$((written + ttl - $(date +%s)))
      if [ "$left" -gt 0 ]; then
        if [ "$left" -ge 3600 ]; then
          cache=" ${DIM}cache $((left / 3600))h$(((left % 3600) / 60))m${R}"
        elif [ "$left" -ge 60 ]; then
          cache=" ${DIM}cache $((left / 60))m${R}"
        else
          cache=" ${YELLOW}cache ${left}s${R}"
        fi
      fi
    fi
  fi
fi

# subscription quota when present (Pro/Max), otherwise API spend.
# rate_limits is absent on API billing, so this self-detects per machine.
usage=""
if [ -n "$quota" ]; then
  usage=" $(color_pct "$quota" bad)5h:${quota%.*}%${R}"
elif [ -n "$cost" ]; then
  spend=$(printf '%.2f' "$cost" 2>/dev/null)
  # smart hiding: an untouched session reads as noise
  [ "$spend" != "0.00" ] && usage=" ${DIM}\$${spend}${R}"
fi

# lines touched this session, hidden until something actually changes
diff=""
if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
  diff=" ${GREEN}+${added}${R}${DIM}/${R}${RED}-${removed}${R}"
fi

# assemble
line="${user}@${host} ${dir}"
[ -n "$branch" ] && line="${line} ${branch}"
if [ -n "$model" ]; then
  line="${line} | ${model}"
  [ -n "$effort" ] && line="${line} ${DIM}${effort}${R}"
fi
line="${line} [$(date +%H:%M)]${ctx}${cache}${diff}${usage}"

printf '%b' "$line"
