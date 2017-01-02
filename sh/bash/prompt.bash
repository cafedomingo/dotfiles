#!/usr/bin/env bash

GIT_PROMPT_START="${Cyan}\w${Color_Off}"
GIT_PROMPT_END="\n${IBlack}\@ 🍤 ${Color_Off}"
source $(dirname $BASH_SOURCE)/bash-git-prompt/gitprompt.sh
