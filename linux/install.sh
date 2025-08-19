#!/usr/bin/env bash

set -euo pipefail

# colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# check if running on supported Linux distribution
check_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|raspbian)
                log "detected: $ID"
                ;;
            *)
                warn "untested distro: $ID"
                ;;
        esac
    else
        warn "unknown distro"
    fi
}

# install packages from packages.list
install_packages() {
    log "installing packages..."

    # filter out comments and empty lines
    packages=$(grep -v '^#' "$(dirname "$0")/packages.list" | grep -v '^$' | tr '\n' ' ')

    if [[ -n "$packages" ]]; then
        sudo apt install -y $packages
    else
        warn "no packages found"
    fi
}

# main installation process
main() {
    # check if we're in the right directory
    if [[ ! -f "$(dirname "$0")/packages.list" ]]; then
        error "packages.list not found. Make sure you're running this from the linux directory."
        exit 1
    fi

    check_distro

    sudo apt update
    install_packages

    # clean up
    log "cleaning up..."
    sudo apt autoremove -y
    sudo apt autoclean

    log "done!"
}

# Run main function
main "$@"
