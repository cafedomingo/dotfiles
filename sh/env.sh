#!/usr/bin/env sh

export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'

# gem / ruby
export GEM_HOME=$HOME/.gem
export GEM_PATH=$GEM_HOME
# homebrew
export HOMEBREW_CASK_OPTS='--appdir=/Applications' # set cask install directory
# android
if [[ -d $HOME/Library/Android/sdk ]]; then
  export ANDROID_SDK=$HOME/Library/Android/sdk
  export ANDROID_HOME=$HOME/Library/Android/sdk
  if [[ -d $HOME/Library/Android/sdk/ndk-bundle ]]; then
    export ANDROID_NDK=$HOME/Library/Android/sdk/ndk-bundle
  fi
fi

# java
if [[ $(/usr/libexec/java_home &> /dev/null) ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi;
# node
if [[ -d /usr/local/lib/node_modules ]]; then
  export NODE_PATH=/usr/local/lib/node_modules:$NODE_PATH
fi

# PATH
paths=(
  /usr/local/bin /usr/local/sbin                                # homebrew
  /usr/local/opt/coreutils/libexec/gnubin                       # homebrew GNU utilities (via brew --prefix coreutils)
  $GEM_HOME/bin                                                 # gem
  $HOME/.rvm/bin                                                # rvm
  /Library/Frameworks/Mono.framework/Versions/Current/Commands  # xamarin
  $HOME/.bin $HOME/bin                                          # user
)
for search_path in ${paths[@]}; do
  [[ -d $search_path ]] \
  && [[ $PATH != *$search_path* ]] \
  && PATH=$search_path:$PATH
done
export PATH

# MANPATH
paths=(
  /usr/local/opt/coreutils/libexec/gnuman # homebrew GNU utilities
  /usr/local/opt/findutils/share/man      # homebrew find utilities
)
for search_path in ${paths[@]}; do
  [[ -d $search_path ]] \
  && [[ $MANPATH != *$search_path* ]] \
  && MANPATH=$search_path:$MANPATH
done
export MANPATH

# cleanup
unset paths
unset search_path

# pager highlighting
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# default editors
# http://unix.stackexchange.com/a/4861
export EDITOR='vi -e'
export VISUAL='subl -w'

# turn on tab-complete for commands and file/dir without typing a letter
set autolist=ambiguous

# keep history up to date, across sessions, in realtime
# http://unix.stackexchange.com/a/48113
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=$HISTSIZE
type shopt &> /dev/null && shopt -s histappend
export HISTIGNORE='&:ls:[bf]g:exit:history'
# save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
