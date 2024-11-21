#!/usr/bin/env zsh

() {
  local -r plugin_dir="$(dirname "${(%):-%x}")/plugins"
  local -r plugins=(
    zsh-syntax-highlighting    # Load this last for best compatibility
    zsh-history-substring-search
    zsh-autosuggestions
  )

  for plugin in ${plugins:|tac}; do 
    source "$plugin_dir/$plugin/$plugin.zsh"
  done
}
