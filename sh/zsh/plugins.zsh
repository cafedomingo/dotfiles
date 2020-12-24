#!/usr/bin/env zsh

plugins="$(dirname "${(%):-%x}")"/plugins

source $plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source $plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# cleanup
unset plugins
