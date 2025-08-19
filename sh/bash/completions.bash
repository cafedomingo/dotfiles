if command -v "brew" &> /dev/null && [[ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]]; then
  # use brew installed `homebrew/versions/bash-completion2`
  # includes any other brew installed completions - brew, gem, git, rake, launchctl, etc.
  source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion;
fi;

# z (smart directory jumping)
if command -v brew >/dev/null 2>&1 && [[ -r "$(brew --prefix)/etc/profile.d/z.sh" ]]; then
  source "$(brew --prefix)/etc/profile.d/z.sh"
elif [[ -r "/usr/share/z/z.sh" ]]; then
  source "/usr/share/z/z.sh"
fi

# fzf completions and key bindings
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi
