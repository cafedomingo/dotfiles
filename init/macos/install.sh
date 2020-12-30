#!/usr/bin/env bash

# xcode cli tools: https://developer.apple.com/download/more/
xcode-select --install

# homebrew: http://brew.sh
if [[ command -v "brew" &> /dev/null ]]; then
  brew update &> /dev/null
  brew upgrade &> /dev/null
else
  printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
  # └─ simulate the ENTER keypress
fi

# install packages
brew tap 'homebrew/bundle'
brew bundle --file="$./Brewfile"
brew bundle --file="./Brewfile.cask"

# set macOS prefs
source "./prefs.sh"

# cleanup
brew cleanup
