#!/usr/bin/env bash

set -euo pipefail

# install or update starship prompt
curl -fsSL https://starship.rs/install.sh | sh -s -- --bin-dir="${HOME}/bin" --yes | sed '/Please follow the steps for your shell/,$d'
