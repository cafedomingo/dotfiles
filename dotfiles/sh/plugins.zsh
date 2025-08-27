() {
  local -r plugin_dir="$(dirname "${(%):-%x}")/plugins"
  local -r plugins=(
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search  # Must load after zsh-syntax-highlighting
  )

  for plugin in ${plugins}; do
    source "$plugin_dir/$plugin/$plugin.zsh"
  done
}
