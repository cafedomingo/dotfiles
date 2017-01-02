#!/usr/bin/env sh

source ./util.sh

if is_macos; then
  . macos/prefs.sh
  . macos/install.sh
fi;

. gem.sh
. npm.sh
