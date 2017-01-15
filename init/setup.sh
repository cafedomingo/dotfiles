#!/usr/bin/env sh

location=$(dirname $([ -z $BASH_SOURCE ] && echo ${(%):-%x} || echo $BASH_SOURCE))
source $location/util.sh

if is_macos; then
  source $location/macos/prefs.sh
  source $location/macos/install.sh
fi;

source $location/gem.sh
source $location/npm.sh
