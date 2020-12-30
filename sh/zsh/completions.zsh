#!/usr/bin/env zsh

function {
  local completions="$(dirname "${(%):-%x}")"/plugins

  # Load completions
  local fpaths=(
    "$completions/zsh-completions"                # standard zsh completions
  )

  # completions for homebrew packages
  if command -v brew &>/dev/null; then
    fpaths=( "$(brew --prefix)/share/zsh/site-functions" $fpaths)
  fi

  for search_path in "${fpaths[@]}"; do
    [[ -d $search_path ]] \
    && [[ $fpath != *$search_path* ]] \
    && fpath=( $search_path $fpath )
  done

  autoload -Uz compinit
  compinit
}
