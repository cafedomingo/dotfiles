() {
  local -r files=(
    ~/.sh/env.sh
    ~/.env.local
    ~/.sh/zsh/options.zsh
    ~/.sh/zsh/plugins.zsh
    ~/.sh/zsh/completions.zsh
    ~/.sh/zsh/prompt.zsh
    ~/.sh/functions.sh
    ~/.sh/aliases.sh
    ~/.sh/zsh/aliases.zsh
    ~/.zshrc.local
    ~/.aliases.local
  )

  for file in $files; do
    [[ -s $file ]] && source "$file"
  done
}