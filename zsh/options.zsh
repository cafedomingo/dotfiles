## docs: https://zsh.sourceforge.io/Doc/Release
# history configuration
HISTSIZE=500000
SAVEHIST=100000
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history # macOS /etc/zshrc sets this, debian does not
setopt extended_history                 # add timestamps to history
setopt hist_ignore_all_dups
setopt hist_ignore_space  # ignore commands starting with space
setopt hist_reduce_blanks # remove unnecessary blanks
setopt share_history      # share history between sessions (implies inc_append_history)

# directory navigation
DIRSTACKSIZE=16
setopt auto_cd           # 'dir' executes 'cd dir'
setopt cdable_vars       # attempt to expand non-directory arguments for cd command
setopt auto_pushd        # cd pushes to directory stack
setopt pushd_ignore_dups # ignore duplicates
setopt pushd_minus       # exchange meaning of - and +
setopt pushd_silent      # do not print the directory stack after pushd or popd
setopt pushd_to_home     # pushd with no arguments acts like ‘pushd $HOME’

# completion
setopt always_to_end    # move cursor to end after completion
setopt auto_menu        # show menu completion after multiple tabs
setopt complete_in_word # complete at the point of the cursor
unsetopt menu_complete  # do not autoselect first completion

# correction
setopt correct # suggest corrections for mistyped commands
SPROMPT="Correct '%R' to '%r'? [Yes/No/Edit/Abort] "

# keybindings
bindkey -e # use emacs keybindings (Ctrl+A, Ctrl+E, etc.)

# Set tab title to current directory
autoload -Uz add-zsh-hook

set_tab_title() {
  print -Pn "\e]1;%~\a"
}

add-zsh-hook precmd set_tab_title

# help system
() {
  local help_dirs=(
    "/usr/share/zsh/$ZSH_VERSION/help/"
    "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/$ZSH_VERSION/help/"
  )

  local dir
  for dir in $help_dirs; do
    [[ -d $dir ]] && export HELPDIR=$dir && break
  done

  unalias run-help 2>/dev/null
  autoload -Uz run-help run-help-git
}
