#!/usr/bin/env zsh

alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g NULL="&> /dev/null"

if is-at-least 4.2.0; then
  # list whats inside packed files
  alias -s 7z="7za l "
  alias -s rar="unrar l"
  alias -s tar="tar tf "
  alias -s tar.gz="echo "
  alias -s tgz="echo "
  alias -s zip="unzip -l "
fi
