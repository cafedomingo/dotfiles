#!/usr/bin/env sh

location=$(dirname "$([ -z "${BASH_SOURCE[0]}" ] && echo "${(%):-%x}" || echo "${BASH_SOURCE[0]}")")

if [ $(uname -s) = "Darwin" ]; then
  source "$location"/macos/prefs.sh
  source "$location"/macos/install.sh
fi;

source "$location"/gem.sh
source "$location"/npm.sh
