#!/usr/bin/env bash

set -euo pipefail

# global variables
DRY_RUN=false
BREW_CMD=""

# helper functions
run_or_show() {
  local description="$1"
  local command="$2"

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "→ Would $description"
  else
    echo "$description..."
    eval "$command" || { echo "❌ Failed to $description"; exit 1; }
  fi
}

# parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-n|--dry-run] [-h|--help]"
      echo "  -n, --dry-run  Show what would be installed without making changes"
      echo "  -h, --help     Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h or --help for usage information"
      exit 1
      ;;
  esac
done

readonly DRY_RUN
[[ "$DRY_RUN" == "true" ]] && echo "=== DRY RUN MODE - NO CHANGES WILL BE MADE ==="

# determine script location for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# xcode cli tools
if xcode-select -p &> /dev/null; then
  echo "✓ Xcode CLI tools already available"
elif [[ "$DRY_RUN" == "true" ]]; then
  echo "→ Would install Xcode CLI tools"
else
  xcode-select --install
  echo "Finish the install in the dialog that opened, then re-run this script."
  exit 1
fi

# homebrew: http://brew.sh
# set BREW_CMD based on architecture
if [[ "$(uname -m)" == "arm64" ]]; then
  BREW_CMD="/opt/homebrew/bin/brew"
else
  BREW_CMD="/usr/local/bin/brew"
fi
readonly BREW_CMD

if [[ -x "$BREW_CMD" ]]; then
  run_or_show "update and upgrade Homebrew" "\"$BREW_CMD\" update && \"$BREW_CMD\" upgrade"
else
  run_or_show "install Homebrew" \
    "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
fi

# install packages
if [[ "$DRY_RUN" == "true" ]]; then
  if [[ -x "$BREW_CMD" ]] && "$BREW_CMD" --version &> /dev/null; then
    echo "Checking Brewfile dependencies..."
    if "$BREW_CMD" bundle check --file="$SCRIPT_DIR/Brewfile" --verbose; then
      echo "✓ All Brewfile dependencies are installed"
    else
      echo "→ Would install missing packages from Brewfile"
    fi
  else
    echo "→ Would install packages from Brewfile (after Homebrew installation)"
  fi
else
  run_or_show "install packages from Brewfile" "\"$BREW_CMD\" bundle --file=\"$SCRIPT_DIR/Brewfile\""
  run_or_show "clean up Homebrew" "\"$BREW_CMD\" cleanup"
fi

# configure macOS preferences
if [[ "$DRY_RUN" == "true" ]]; then
  "$SCRIPT_DIR/prefs.sh" --dry-run
else
  "$SCRIPT_DIR/prefs.sh"
fi

# completion message
echo ""
if [[ "$DRY_RUN" == "true" ]]; then
  echo "=== DRY RUN COMPLETE ==="
  echo "✓ All operations would complete successfully"
else
  echo "=== INSTALLATION COMPLETE ==="
  echo "✓ All components installed and configured successfully"
fi

