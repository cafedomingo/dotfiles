#!/usr/bin/env zsh

alias help='run-help'

# navigation
alias -- -='cd -'
alias -g ...='../..'
alias -g ....='../../..'

alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g N="&> /dev/null"

# Archive viewers (ZSH 4.2.0+)
is-at-least 4.2.0 && {
  local -rA archives=(
      [7z]='7z l'
      [rar]='unrar l'
      [zip]='unzip -l'
      [tar]='tar tf'
      [tar.gz,tgz]='tar tzf'
  )

  for ext format in ${(kv)archives}; do
    for e in ${(s:,:)ext}; do
      alias -s $e="$format"
    done
  done
}
