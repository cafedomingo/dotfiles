#!/usr/bin/env sh

() {
  local -r location=$(dirname "$([ -z "${BASH_SOURCE[0]}" ] && echo "${(%):-%x}" || echo "${BASH_SOURCE[0]}")")

  # load functions
  for file in "$location"/functions/*.sh; do
    [[ -s $file ]] && source "$file"
  done
}
