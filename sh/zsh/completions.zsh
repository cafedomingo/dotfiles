#!/usr/bin/env zsh

() {
  local -r completions="$(dirname "${(%):-%x}")"/plugins
  local -a fpaths=("$completions/zsh-completions")

  # completions for homebrew packages
  if command -v brew &>/dev/null; then
    fpaths=( "$(brew --prefix)/share/zsh/site-functions" $fpaths)
  fi

  for search_path in "${fpaths[@]}"; do
    [[ -d $search_path ]] \
    && [[ $fpath != *$search_path* ]] \
    && fpath=( $search_path $fpath )
  done

  autoload -Uz compinit && compinit
}

# enable cursor menu selection
zstyle ':completion:*:*:*:*:*' menu select

# case, hyphen and underscore insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

# complete . and .. special directories
zstyle ':completion:*' special-dirs true

# use cashe
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR

# show colors on completion suggestions
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
