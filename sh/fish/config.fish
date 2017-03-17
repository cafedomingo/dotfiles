set -gx LANG 'en_US.UTF-8'
set -gx LANGUAGE 'en_US:en'

# gem / ruby
set -gx GEM_HOME $HOME/.gem
set -gx GEM_PATH $GEM_HOME
# homebrew
set -gx HOMEBREW_CASK_OPTS '--appdir=/Applications' # set cask install directory
# android
if test -d $HOME/Library/Android/sdk
  set -gx ANDROID_SDK $HOME/Library/Android/sdk
end
# java
if /usr/libexec/java_home > /dev/null ^ /dev/null
  set -gx JAVA_HOME (/usr/libexec/java_home)
end
# node
if test -d /usr/local/lib/node_modules
  set -gx NODE_PATH /usr/local/lib/node_modules $NODE_PATH
end

# PATH
set -l paths /usr/local/bin /usr/local/sbin                                       # homebrew
set -l paths $paths /usr/local/opt/coreutils/libexec/gnubin                       # homebrew GNU utilities
set -l paths $paths $GEM_HOME/bin                                                 # gem
set -l paths $paths $HOME/.rvm/bin                                                # rvm
set -l paths $paths /Library/Frameworks/Mono.framework/Versions/Current/Commands  # xamarin
set -l paths $paths $HOME/.bin $HOME/bin                                          # user

for path in $paths[-1..1]
  test -d $path; and not contains $path $PATH; and set PATH $path $PATH
end

# MANPATH
set -l paths /usr/local/opt/coreutils/libexec/gnuman    # homebrew GNU utilities
set -l paths $paths /usr/local/opt/findutils/share/man  # homebrew find utilities

for path in $paths[-1..1]
  test -d $path; and not contains $path $MANPATH; and set MANPATH $path $MANPATH
end

# highlighted `man` pages
set -gx LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
set -gx LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
set -gx LESS_TERMCAP_me \e'[0m'           # end mode
set -gx LESS_TERMCAP_se \e'[0m'           # end standout-mode
set -gx LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
set -gx LESS_TERMCAP_ue \e'[0m'           # end underline
set -gx LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

# default editors
# http://unix.stackexchange.com/a/4861
set -gx EDITOR 'vi -e'
set -gx VISUAL 'subl -w'
