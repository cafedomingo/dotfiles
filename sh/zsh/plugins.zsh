#!/usr/bin/env zsh

export PLUGINS="$(dirname "${(%):-%x}")"/plugins

source $PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh
source $PLUGINS/zsh-history-substring-search/zsh-history-substring-search.zsh
source $PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
