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

# archive viewers
alias -s 7z='7z l'
alias -s rar='unrar l'
alias -s zip='unzip -l'
alias -s tar='tar tf'
alias -s tgz='tar tzf'
alias -s 'tar.gz'='tar tzf'
