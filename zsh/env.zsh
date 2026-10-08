# locale
case "$OSTYPE" in
  linux*)
    if locale -a 2>/dev/null | grep -q 'en_US.utf8'; then
      export LANG='en_US.UTF-8'
      export LANGUAGE='en_US:en'
      export LC_CTYPE='en_US.UTF-8'
    else
      export LANG='C.UTF-8'
      export LC_CTYPE='C.UTF-8'
    fi
    ;;
  darwin*)
    export LANG='en_US.UTF-8'
    export LC_CTYPE='en_US.UTF-8'
    ;;
esac

# default editors
export EDITOR='vi'
if [[ "$OSTYPE" == darwin* ]]; then
  export VISUAL='subl -w'
fi

### conditional exports
# java
java_home_path="$(/usr/libexec/java_home 2>/dev/null)"
if [[ -n $java_home_path ]]; then
  export JAVA_HOME="$java_home_path"
fi

# PATH
paths=(
  /opt/homebrew/bin /opt/homebrew/sbin # homebrew (arm64)
  /usr/local/go/bin                    # go
  "$HOME/.local/bin"                   # user-specific executable files
  "$HOME/.bin" "$HOME/bin"             # personal executables
)

for p in "${paths[@]}"; do
  if [[ -d "$p" ]]; then
    case ":$PATH:" in
      *":$p:"*) ;;
      *) PATH="$p:$PATH" ;;
    esac
  fi
done
export PATH

# eza defaults to ~/Library/Application Support on macOS
export EZA_CONFIG_DIR="$HOME/.config/eza"

# pagers
export PAGER="less -RF"
if (($+commands[groff])); then
  export MANROFFOPT="-c"
fi
if less --use-color -Dk -F -X </dev/null >/dev/null 2>&1; then
  export MANPAGER="less -R -X -F --use-color -Dd+G -Du+B"
else
  export MANPAGER="less -R -X -F"
fi

# fzf (fuzzy finder) - environment variables only
if (($+commands[fzf])); then
  # Default options
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

  # Use ripgrep for file finding if available
  if (($+commands[rg])); then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi

# cleanup
unset paths p java_home_path
