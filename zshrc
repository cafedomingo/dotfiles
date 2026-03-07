() {
  local -r files=(
    ~/.sh/options.zsh
    ~/.sh/plugins.zsh
    ~/.sh/completions.zsh
    ~/.sh/prompt.zsh
    ~/.sh/functions.sh
    ~/.sh/aliases.sh
    ~/.zshrc.local
    ~/.aliases.local
  )

  for file in $files; do
    [[ -s $file ]] && source "$file"
  done
}
