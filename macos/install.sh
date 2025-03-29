#!/usr/bin/env bash

set -euo pipefail

# xcode cli tools: https://developer.apple.com/download/more/
if ! xcode-select -p &> /dev/null; then
  xcode-select --install
fi

# homebrew: http://brew.sh
if command -v "brew" &> /dev/null; then
  BREW_CMD="brew"
  brew upgrade && brew cleanup
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # determine the correct homebrew path based on architecture
  if [[ "$(uname -m)" == "arm64" ]]; then
    BREW_CMD="/opt/homebrew/bin/brew"
  else
    BREW_CMD="/usr/local/bin/brew"
  fi
fi

# install packages
"$BREW_CMD" bundle --file="./Brewfile"

# set macOS prefs
source "./prefs.sh"

# cleanup
"$BREW_CMD" cleanup
