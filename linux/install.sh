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

# parse command line arguments
DRY_RUN=false
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

packages=()
while IFS= read -r package; do
    [[ -n "$package" ]] && packages+=("$package")
done < <(grep -vE '^\s*(#|$)' "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/packages.list")

if [[ "$DRY_RUN" == "true" ]]; then
    if [[ ${#packages[@]} -eq 0 ]]; then
        warn "No packages to install"
    else
        log "Would install ${#packages[@]} packages:"
        printf '  %s\n' "${packages[@]}"
    fi
    echo "=== DRY RUN COMPLETE ==="
    exit 0
fi

sudo apt update || { err "apt update failed"; exit 1; }

if [[ ${#packages[@]} -eq 0 ]]; then
    warn "No packages to install"
else
    log "Installing ${#packages[@]} packages..."
    sudo apt install -y "${packages[@]}" || warn "Some packages failed or were unavailable"
fi

sudo apt autoclean
