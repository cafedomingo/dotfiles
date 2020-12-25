#!/usr/bin/env zsh

completions="$(dirname "${(%):-%x}")"/plugins

# Load completions
fpaths=(
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

# Case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

autoload -Uz compinit
compinit

# cleanup
unset completions
unset fpaths
