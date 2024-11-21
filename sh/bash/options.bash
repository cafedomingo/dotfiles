#!/usr/bin/env bash

# keep history up to date, across sessions, in realtime
# http://unix.stackexchange.com/a/48113
HISTCONTROL=ignoredups:erasedups
HISTSIZE=100000
HISTFILESIZE=$HISTSIZE
HISTIGNORE='&:ls:[bf]g:exit:history'

# enable history appending and immediate sharing between sessions
shopt -s histappend 2>/dev/null
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND:-}"
