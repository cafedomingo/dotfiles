#!/usr/bin/env sh

source ./util.sh

if is_macos; then
  source macos/prefs.sh
  source macos/install.sh
fi;

source gem.sh
source npm.sh
