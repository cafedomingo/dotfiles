#!/usr/bin/env bash

if  has_homebrew && [[ -f $(brew --prefix)/share/bash-completion/bash_completion ]]; then
  # use brew installed `homebrew/versions/bash-completion2`
  # includes any other brew installed completions - brew, gem, git, rake, launchctl, etc.
  . $(brew --prefix)/share/bash-completion/bash_completion;
elif [[ -f /etc/bash_completion ]]; then
  . /etc/bash_completion;
fi;
