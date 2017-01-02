#!/usr/bin/env zsh

source $(dirname ${(%):-%x})/antigen/antigen.zsh

antigen use oh-my-zsh

bundles=(
  git
  tarruda/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-syntax-highlighting
)

for bundle in ${bundles[@]}; do
  antigen bundle $bundle
done

if [[ is_macos ]]; then
  antigen bundle osx
fi

antigen theme avit

antigen apply
