#!/usr/bin/env sh

# load RVM into a shell *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

location=$(dirname $([ -z $BASH_SOURCE ] && echo ${(%):-%x} || echo $BASH_SOURCE))

# load functions
for file in $location/functions/*.sh; do
  [[ -s $file ]] && source $file
done
