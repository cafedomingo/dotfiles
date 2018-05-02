#!/usr/bin/env zsh

source $(dirname ${(%):-%x})/antigen/antigen.zsh

antigen use oh-my-zsh

## Bundles
bundles=(
  git
  gitignore
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-syntax-highlighting
)

for bundle in ${bundles[@]}; do
  antigen bundle $bundle
done

if [[ is_macos ]]; then
  antigen bundle osx
fi

## Configure prompt
# Spaceship documentation: https://denysdovhan.com/spaceship-prompt
SPACESHIP_DIR_TRUNC=0
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_GIT_SYMBOL=''
SPACESHIP_HOST_PREFIX='@ '
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_PREFIX=''
SPACESHIP_TIME_COLOR='#121212'
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  host          # Hostname section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  node          # Node.js section
  ruby          # Ruby section
  xcode         # Xcode section
  swift         # Swift section
  golang        # Go section
  docker        # Docker section
  aws           # Amazon Web Services section
  venv          # virtualenv section
  pyenv         # Pyenv section
  dotnet        # .NET section
  exec_time     # Execution time
  line_sep      # Line break
  battery       # Battery level and status
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  time          # Time stampts section
  exit_code     # Exit code section
  char          # Prompt character
)
antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship

antigen apply
