#!/usr/bin/env bash

set -euo pipefail

# colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

sudo apt update

packages=()
while IFS= read -r package; do
    [[ -n "$package" ]] && packages+=("$package")
done < <(grep -v '^#' "$(dirname "$0")/packages.list" | grep -v '^\s*$')

if [[ ${#packages[@]} -eq 0 ]]; then
    warn "No packages to install"
else
    log "Installing ${#packages[@]} packages..."
    sudo apt install -y "${packages[@]}" || warn "Some packages failed or were unavailable"
fi

sudo apt autoclean
