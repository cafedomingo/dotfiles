#!/usr/bin/env sh

export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'

# gem / ruby
export GEM_HOME="$HOME/.gem"
export GEM_PATH="$GEM_HOME"
# homebrew
if command -v brew &>/dev/null; then
  export HOMEBREW_CASK_OPTS='--appdir=/Applications' # set cask install directory
fi;
# android
if [[ -d $HOME/Library/Android/sdk ]]; then
  export ANDROID_SDK="$HOME/Library/Android/sdk"
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  if [[ -d "$HOME/Library/Android/sdk/ndk-bundle" ]]; then
    export ANDROID_NDK="$HOME/Library/Android/sdk/ndk-bundle"
  fi
fi;
# java
if [[ $(/usr/libexec/java_home 2> /dev/null) ]]; then
  export JAVA_HOME="$(/usr/libexec/java_home)"
fi;
# node
if [[ -d /usr/local/lib/node_modules ]]; then
  export NODE_PATH=/usr/local/lib/node_modules:$NODE_PATH
fi;

# PATH
paths=(
  "$GEM_HOME/bin"                                         # gem
  "$ANDROID_HOME/tools" "$ANDROID_HOME/platform-tools"    # android
  /usr/local/opt/coreutils/libexec/gnubin                 # homebrew GNU utilities (intel)
  /usr/local/bin /usr/local/sbin                          # homebrew (intel)
  /opt/homebrew/opt/coreutils/libexec/gnubin              # homebrew GNU utilities (arm64)
  /opt/homebrew/bin /opt/homebrew/sbin                    # homebrew (arm64)
  "$HOME/.bin" "$HOME/bin"                                # user
)
for search_path in "${paths[@]}"; do
  [[ -d $search_path ]] \
  && [[ $PATH != *$search_path* ]] \
  && PATH=$search_path:$PATH
done
export PATH

# MANPATH
paths=(
  /usr/local/opt/coreutils/libexec/gnuman       # homebrew GNU utilities (intel)
  /usr/local/opt/findutils/share/man            # homebrew find utilities (intel)
  /opt/homebrew/opt/coreutils/libexec/gnuman    # homebrew GNU utilities (arm64)
  /opt/homebrew/opt/findutils/share/man         # homebrew find utilities (arm64)
)
for search_path in "${paths[@]}"; do
  [[ -d $search_path ]] \
  && [[ $MANPATH != *$search_path* ]] \
  && MANPATH=$search_path:$MANPATH
done
export MANPATH

# pager highlighting
export LESS_TERMCAP_mb=$'\e[1;32m'    # begin blinking
export LESS_TERMCAP_md=$'\e[1;32m'    # begin bold
export LESS_TERMCAP_me=$'\e[0m'       # end mode
export LESS_TERMCAP_se=$'\e[0m'       # end standout-mode
export LESS_TERMCAP_so=$'\e[01;33m'   # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'       # end underline
export LESS_TERMCAP_us=$'\e[1;4;31m'  # begin underline

# default editors
# http://unix.stackexchange.com/a/4861
export EDITOR='vi -e'
export VISUAL='subl -w'

# cleanup
unset paths
unset search_path
