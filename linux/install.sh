#!/usr/bin/env bash

set -euo pipefail

# colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

err() {
    echo -e "${RED}[ERR]${NC} $1" >&2
}

sudo apt update || { err "apt update failed"; exit 1; }

packages=()
while IFS= read -r package; do
    [[ -n "$package" ]] && packages+=("$package")
done < <(grep -vE '^\s*(#|$)' "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/packages.list")

if [[ ${#packages[@]} -eq 0 ]]; then
    warn "No packages to install"
else
    log "Installing ${#packages[@]} packages..."
    sudo apt install -y "${packages[@]}" || warn "Some packages failed or were unavailable"
fi

sudo apt autoclean
