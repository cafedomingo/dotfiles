() {
  local -r files=(
    ~/.zsh/options.zsh
    ~/.zsh/plugins.zsh
    ~/.zsh/completions.zsh
    ~/.zsh/prompt.zsh
    ~/.zsh/functions.zsh
    ~/.zshrc.local
  )

  local file
  for file in $files; do
    [[ -s $file ]] && source "$file"
  done

  # .zshrc is interactive-only by convention, but Claude Code sources it
  # for its non-interactive shell. Guard aliases explicitly so they don't
  # affect tool invocations.
  if [[ -o interactive ]]; then
    [[ -s ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
    [[ -s ~/.aliases.local ]] && source ~/.aliases.local
  fi
}
