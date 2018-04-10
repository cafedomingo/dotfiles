#!/usr/bin/env bash

GIT_PROMPT_START="${BBlue}\w${Color_Off}"
GIT_PROMPT_END="\n${IBlack}\@ ${White}▶ ${Color_Off}"
source $(dirname $BASH_SOURCE)/bash-git-prompt/gitprompt.sh
