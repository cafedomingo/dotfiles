#!/usr/bin/env zsh

alias help='run-help'

# navigation
alias -- -='cd -'
alias -g ...='../..'
alias -g ....='../../..'

# global aliases for common pipes and redirections
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g N="&> /dev/null"

# archive viewers
alias -s 7z='7z l'
alias -s rar='unrar l'
alias -s tar='tar tf'
alias -s tgz='tar tzf'
alias -s 'tar.gz'='tar tzf'
alias -s tbz='tar tjf'
alias -s tbz2='tar tjf'
alias -s 'tar.bz2'='tar tjf'
alias -s txz='tar tJf'
alias -s 'tar.xz'='tar tJf'
alias -s taz='tar tZf'
alias -s 'tar.Z'='tar tZf'
alias -s zip='unzip -l'
