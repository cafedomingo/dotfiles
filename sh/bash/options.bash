#!/usr/bin/env bash

# keep history up to date, across sessions, in realtime
# http://unix.stackexchange.com/a/48113
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=$HISTSIZE
type shopt &> /dev/null && shopt -s histappend
export HISTIGNORE='&:ls:[bf]g:exit:history'
# save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
