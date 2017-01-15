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
  [[ $(uname -s) == Darwin ]]
  return $?
}

# determines if the current shell is bash
function is_bash() {
  [[ ! -z $BASH_VERSION ]]
  return $?
}

# determines if the current shell is zsh
function is_zsh() {
  [[ ! -z $ZSH_VERSION ]]
  return $?
}
