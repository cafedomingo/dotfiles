#!/usr/bin/env bash

if command -v "brew" &> /dev/null && [[ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]]; then
  # use brew installed `homebrew/versions/bash-completion2`
  # includes any other brew installed completions - brew, gem, git, rake, launchctl, etc.
  source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion;
fi;
