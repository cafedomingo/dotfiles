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

while IFS= read -r package; do
    if [[ -n "$package" ]]; then
        log "installing $package..."
        if sudo apt install -y "$package"; then
            log "✓ $package installed successfully"
        else
            warn "✗ $package not available or failed to install, continuing..."
        fi
    fi
done < <(grep -v '^#' "$(dirname "$0")/packages.list" | grep -v '^\s*$')

sudo apt autoclean
