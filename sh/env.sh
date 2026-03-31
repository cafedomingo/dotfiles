# locale
case "$OSTYPE" in
  linux*)
    if locale -a 2>/dev/null | grep -q 'en_US.utf8'; then
      export LANG='en_US.UTF-8'
      export LANGUAGE='en_US:en'
    else
      export LANG='C.UTF-8'
    fi
    ;;
  darwin*)
    export LANG='en_US.UTF-8'
    export LC_CTYPE='en_US.UTF-8'
    ;;
esac

# gpg
GPG_TTY=$(tty)
export GPG_TTY

# default editors
export EDITOR='vi'
if [[ "$OSTYPE" == darwin* ]]; then
  export VISUAL='subl -w'
fi

# pager highlighting
if less --use-color -Dk -F -X </dev/null >/dev/null 2>&1; then
  export MANPAGER="less -R -X -F --use-color -Dd+G -Du+B"
else
  export MANPAGER="less -R -X -F"
fi

### conditional exports
# java
if command -v /usr/libexec/java_home >/dev/null 2>&1; then
  java_home_path="$('/usr/libexec/java_home' 2>/dev/null)"
  if [[ -n $java_home_path ]]; then
    export JAVA_HOME="$java_home_path"
  fi
fi

# PATH
paths=(
  "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"            # android cmdline-tools
  /opt/homebrew/opt/coreutils/libexec/gnubin              # homebrew GNU utilities (arm64)
  /opt/homebrew/bin /opt/homebrew/sbin                    # homebrew (arm64)
  /usr/local/go/bin                                       # go
  "$HOME/.local/bin"                                      # user-specific executable files
  "$HOME/.bin" "$HOME/bin"                                # personal executables
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

# MANPATH
manpaths=(
  /opt/homebrew/opt/coreutils/libexec/gnuman
  /opt/homebrew/opt/findutils/share/man
)

mp=""
for p in "${manpaths[@]}"; do
  [[ -d "$p" ]] && mp="${mp:+$mp:}$p"
done

if [[ -n $mp ]]; then
  if [[ -z ${MANPATH:-} ]]; then
    export MANPATH="${mp}:"
  else
    export MANPATH="${mp}:${MANPATH}"
  fi
fi

# fzf (fuzzy finder) - environment variables only
if command -v fzf >/dev/null 2>&1; then
  # Default options
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

  # Use ripgrep for file finding if available
  if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  fi
fi

# cleanup
unset paths manpaths p mp java_home_path
