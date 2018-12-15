#!/usr/bin/env sh

# load RVM into a shell *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

if [[ -n "${BASH_SOURCE[0]}" ]]; then
  location=$(dirname "${BASH_SOURCE[0]}")
else
  location=$(dirname "${(%):-%x}")
fi

# load functions
for file in "$location"/functions/*.sh; do
  [[ -s $file ]] && source "$file"
done
