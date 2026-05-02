() {
  local -r files=(
    ~/.sh/options.zsh
    ~/.sh/plugins.zsh
    ~/.sh/completions.zsh
    ~/.sh/prompt.zsh
    ~/.sh/functions.sh
    ~/.zshrc.local
  )

  for file in $files; do
    [[ -s $file ]] && source "$file"
  done

  # .zshrc is interactive-only by convention, but Claude Code sources it
  # for its non-interactive shell. Guard aliases explicitly so they don't
  # affect tool invocations.
  if [[ -o interactive ]]; then
    [[ -s ~/.sh/aliases.sh ]] && source ~/.sh/aliases.sh
    [[ -s ~/.aliases.local ]] && source ~/.aliases.local
  fi
}
