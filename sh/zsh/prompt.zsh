#!/usr/bin/env zsh

## Configure prompt
# Spaceship documentation: https://denysdovhan.com/spaceship-prompt
SPACESHIP_DIR_TRUNC=0
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_EXEC_TIME_ELAPSED=5
SPACESHIP_GIT_SYMBOL=''
SPACESHIP_HOST_PREFIX='@ '
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_PREFIX=''
SPACESHIP_TIME_COLOR='#63637B'
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  host          # Hostname section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  exec_time     # Execution time
  line_sep      # Line break
  battery       # Battery level and status
  jobs          # Background jobs indicator
  time          # Time stamp section
  exit_code     # Exit code section
  char          # Prompt character
)

fpath=( "$HOME/.zsh/spaceship" $fpath )

autoload -U promptinit; promptinit
prompt spaceship
