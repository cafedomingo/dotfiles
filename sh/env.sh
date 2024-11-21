#!/usr/bin/env sh

# locale
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'

# gpg
export GPG_TTY=$(tty)

# gem / ruby
export GEM_HOME="$HOME/.gem"
export GEM_PATH="$GEM_HOME"

# default editors
# http://unix.stackexchange.com/a/4861
export EDITOR='vi -e'
export VISUAL='subl -w'

# pager highlighting
export MANPAGER="less -R --use-color -Dd+G -Du+B"

# conditional exports
() {
  # homebrew
  command -v brew >/dev/null && 
    export HOMEBREW_CASK_OPTS='--appdir=/Applications'
  
  # android sdk
  [[ -d "$HOME/Library/Android/sdk" ]] && {
    export ANDROID_SDK="$HOME/Library/Android/sdk"
    export ANDROID_HOME="$ANDROID_SDK"
    [[ -d "$ANDROID_SDK/ndk-bundle" ]] && 
      export ANDROID_NDK="$ANDROID_SDK/ndk-bundle"
  }

  # java
  command -v /usr/libexec/java_home >/dev/null &&
    [[ $(/usr/libexec/java_home 2>/dev/null) ]] &&
    export JAVA_HOME="$(/usr/libexec/java_home)"

  # node
  [[ -d /usr/local/lib/node_modules ]] &&
    export NODE_PATH="/usr/local/lib/node_modules${NODE_PATH:+:$NODE_PATH}"

  # PATH
  local -ar paths=(
    "$GEM_HOME/bin"                                         # gem
    "$ANDROID_HOME/tools" "$ANDROID_HOME/platform-tools"    # android
    /opt/homebrew/opt/coreutils/libexec/gnubin              # homebrew GNU utilities (arm64)
    /opt/homebrew/bin /opt/homebrew/sbin                    # homebrew (arm64)
    "$HOME/.bin" "$HOME/bin"                                # user
  )

  # MANPATH
  local -ar manpaths=(
    /opt/homebrew/opt/coreutils/libexec/gnuman
    /opt/homebrew/opt/findutils/share/man
  )
 
 # Add paths if they exist and aren't already in PATH/MANPATH
 for p in ${paths[@]}; do
    [[ -d $p && $PATH != *$p* ]] && PATH="$p:$PATH"
  done

  for p in ${manpaths[@]}; do
    [[ -d $p && $MANPATH != *$p* ]] && MANPATH="$p:$MANPATH"
  done

  export PATH MANPATH
}
