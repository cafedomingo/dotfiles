#!/usr/bin/env sh

is_macos() {
  [[ $(uname -s) == Darwin ]]
  return $?
}

has_homebrew() {
  is_macos && command -v brew &> /dev/null
  return $?
}
