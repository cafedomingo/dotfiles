# locale
export LANG='en_US.UTF-8'
case "$OSTYPE" in
  linux*)  export LANGUAGE='en_US:en' ;;    # gettext uses this
  darwin*) export LC_CTYPE='en_US.UTF-8' ;; # fixes UTF-8 issues in some macOS terminals
esac

# gpg
export GPG_TTY=$(tty)

# default editors
export EDITOR='vi -e'
export VISUAL='subl -w'

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

# node
npm_global_bin=""
if command -v npm >/dev/null 2>&1; then
  npm_prefix="$(npm config get prefix 2>/dev/null)"
  if [[ -n $npm_prefix && -d "$npm_prefix/bin" ]]; then
    npm_global_bin="$npm_prefix/bin"
  fi
fi

# PATH
paths=(
  "$GEM_HOME/bin"                                         # gem
  "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"            # android cmdline-tools
  "$npm_global_bin"                                       # npm global bin
  /opt/homebrew/opt/coreutils/libexec/gnubin              # homebrew GNU utilities (arm64)
  /opt/homebrew/bin /opt/homebrew/sbin                    # homebrew (arm64)
  "$HOME/.bin" "$HOME/bin"                                # user
)

for p in ${paths[@]}; do
  if [[ -d "$p" ]]; then
    case ":$PATH:" in
      *":$p:") ;;
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
for p in ${manpaths[@]}; do
  [[ -d "$p" ]] && mp="${mp:+$mp:}$p"
done

if [[ -n $mp ]]; then
  if [[ -z ${MANPATH:-} ]]; then
    export MANPATH="${mp}:"
  else
    export MANPATH="${mp}:${MANPATH}"
  fi
fi

# cleanup
unset paths manpaths p mp java_home_path npm_global_bin npm_prefix
