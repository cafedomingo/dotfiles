#!/usr/bin/env sh

# determine if a shell command is available
function has() {
  command -v "$1" &> /dev/null
  return $?
}

# determine if homebrew is available
function has_homebrew() {
  is_macos && has brew
  return $?
}

# determine if the system is running macOS
function is_macos() {
  [[ $(uname -s) == "Darwin" ]]
  return $?
}

# determine if the system is running macOS
function is_linux() {
  [[ $(uname -s) == "Linux" ]]
  return $?
}
