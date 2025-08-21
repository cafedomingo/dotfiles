#!/usr/bin/env bash

set -euo pipefail

# xcode cli tools: https://developer.apple.com/download/more/
if ! command -v gcc &> /dev/null; then
  echo "Installing Xcode CLI tools..."

  # non-interactive installation
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  PROD=$(softwareupdate -l | grep "Command Line Tools" | head -n 1 | sed 's/^[^:]*: *//' | sed 's/-.*//' | tr -d '\n')
  softwareupdate -i "$PROD" --verbose
  rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

  echo "✓ Xcode CLI tools installed"
else
  echo "✓ Xcode CLI tools already installed"
fi

# homebrew: http://brew.sh
if command -v "brew" &> /dev/null; then
  echo "✓ Homebrew already installed"
  BREW_CMD="brew"
  brew update && brew upgrade
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ "$(uname -m)" == "arm64" ]]; then
    BREW_CMD="/opt/homebrew/bin/brew"
  else
    BREW_CMD="/usr/local/bin/brew"
  fi

  # verify installation
  if ! command -v "$BREW_CMD" &> /dev/null; then
    echo "❌ Homebrew installation failed"
    exit 1
  fi

  echo "✓ Homebrew installed successfully"
fi

# install packages
echo "Installing packages from Brewfile..."
"$BREW_CMD" bundle --file="./Brewfile"
echo "✓ Package installation complete"

# cleanup homebrew
echo "Cleaning up Homebrew..."
"$BREW_CMD" cleanup

# set macOS prefs
echo "Configuring macOS preferences..."
./prefs.sh

