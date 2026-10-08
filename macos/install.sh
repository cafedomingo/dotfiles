#!/usr/bin/env bash

set -euo pipefail

# no options: a leftover -n must not turn into a real install
[[ $# -eq 0 ]] || {
  echo "usage: $0 (for a preview of preferences, run prefs.sh -n)" >&2
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# homebrew: http://brew.sh (its installer also installs the xcode cli tools)
if [[ "$(uname -m)" == "arm64" ]]; then
  BREW_CMD="/opt/homebrew/bin/brew"
else
  BREW_CMD="/usr/local/bin/brew"
fi

# brew bundle upgrades outdated Brewfile entries itself, so no blanket upgrade
if [[ -x "$BREW_CMD" ]]; then
  echo "Updating Homebrew..."
  "$BREW_CMD" update
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
