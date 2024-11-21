#!/usr/bin/env zsh

## docs: http://zsh.sourceforge.net/Doc/Release
# History configuration
export HISTSIZE=500000
export SAVEHIST=100000
setopt append_history      # append history to the zsh_history file
setopt extended_history    # add timestamps to history
setopt hist_ignore_all_dups
setopt hist_ignore_space   # ignore commands starting with space
setopt hist_reduce_blanks  # remove unnecessary blanks
setopt share_history       # share history between sessions NOTE: similiar to inc_append_history

# Directory navigation
export DIRSTACKSIZE=16
setopt auto_cd            # 'dir' executes 'cd dir'
setopt cdable_vars        # attempt to expand non-directory arguments for cd command
setopt auto_pushd         # cd pushes to directory stack
setopt pushd_ignore_dups  # ignore duplicates
setopt pushd_minus        # exchange meaning of - and +
setopt pushd_silent       # do not print the directory stack after pushd or popd
setopt pushd_to_home      # pushd with no arguments acts like ‘pushd $HOME’

# Completion
setopt always_to_end      # move cursor to end after completion
setopt auto_menu          # show menu completion after multiple tabs
setopt complete_in_word   # complete at the point of the cursor
unsetopt menu_complete    # do notautoselect first completion

# Prompt
setopt prompt_subst       # enable command substitution in prompt. needed for the suggestion plugins

# Help system
() {
    local help_dirs=(
        "/usr/share/zsh/$ZSH_VERSION/help/"
        "$(brew --prefix 2>/dev/null)/share/zsh/$ZSH_VERSION/help/"
    )
    
    for dir in $help_dirs; do
        [[ -d $dir ]] && export HELPDIR=$dir && break
    done
    
    unalias run-help 2>/dev/null
    autoload -Uz run-help run-help-git
}
