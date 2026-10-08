#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# homebrew: http://brew.sh (its installer also installs the xcode cli tools)
if [[ "$(uname -m)" == "arm64" ]]; then
  BREW_CMD="/opt/homebrew/bin/brew"
else
  BREW_CMD="/usr/local/bin/brew"
fi

if [[ -x "$BREW_CMD" ]]; then
  echo "Updating Homebrew..."
  "$BREW_CMD" update
  "$BREW_CMD" upgrade
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing packages from Brewfile..."
"$BREW_CMD" bundle --file="$SCRIPT_DIR/Brewfile"
"$BREW_CMD" cleanup

# preferences keep their own --dry-run, since defaults writes are hard to undo
"$SCRIPT_DIR/prefs.sh"

echo ""
echo "=== INSTALLATION COMPLETE ==="
