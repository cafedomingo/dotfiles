#!/usr/bin/env zsh

## docs: http://zsh.sourceforge.net/Doc/Release

## history
HISTSIZE=500000
SAVEHIST=100000

# append history to the zsh_history file
setopt append_history

setopt extended_history

# ignore duplicates in history
setopt hist_ignore_all_dups

# ignore commands for history that start with a space
setopt hist_ignore_space

# remove superfluous blanks from each line being added to the history list
setopt hist_reduce_blanks

# import new commands from history and append commands to history incrementally
# NOTE: similiar to inc_append_history with the addition of importing history
setopt share_history

## changing directories
# execute directories as cd command
setopt auto_cd

# attempt to expand non-directory arguments for cd command
setopt cdable_vars

# configure directory stack
DIRSTACKSIZE=16
setopt auto_pushd         # cd pushes to directory stack
setopt pushd_ignore_dups  # ignore duplicates
setopt pushd_minus        # exchange meaning of ‘-‘ and ‘+‘ when navigating stack
setopt pushd_silent       # do not print the directory stack after pushd or popd
setopt pushd_to_home      # pushd with no arguments acts like ‘pushd $HOME’

## prompt
# adds support for command substitution. You'll need this for the suggestion plugins.
setopt prompt_subst

## completion
# jump to end after completion
setopt always_to_end

# show menu completion after multiple tabs
setopt auto_menu
unsetopt menu_complete    # do not autoselect the first completion entry

# enable completion at the point of the cursor
setopt complete_in_word

## help
if [[ -d /usr/share/zsh/$ZSH_VERSION/help/ ]]; then
  # system zsh
  export HELPDIR=/usr/share/zsh/$ZSH_VERSION/help/
elif [[ -d "$(brew --prefix)/share/zsh/$ZSH_VERSION/help/" ]] then
  # homebrew zsh
  export HELPDIR="$(brew --prefix)/share/zsh/$ZSH_VERSION/help/"
fi;
unalias run-help
autoload -Uz run-help
autoload -Uz run-help-git
