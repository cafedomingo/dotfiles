#!/usr/bin/env zsh

source $(dirname ${(%):-%x})/antigen/antigen.zsh

antigen use oh-my-zsh

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

SPACESHIP_GIT_SYMBOL=''
SPACESHIP_CHAR_PREFIX='\033[1;90m%* '
antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship

antigen apply
