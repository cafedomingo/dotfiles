#!/usr/bin/env sh

# determine if a shell command is available
has() {
  command -v "$1" >/dev/null 2>&1
}

# determine if homebrew is available
has_homebrew() {
  has brew
}

# determine if the system is running macOS
is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

# determine if the system is running linux
is_linux() {
  [ "$(uname -s)" = "Linux" ]
}
