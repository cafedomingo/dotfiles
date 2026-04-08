() {
  local -r completions="$(dirname "${(%):-%x}")"/plugins/zsh-completions

  [[ -d $completions ]] \
    && (( ! ${fpath[(I)$completions]} )) \
    && fpath=( $completions $fpath )

  autoload -Uz compinit && compinit
}

# enable cursor menu selection
zstyle ':completion:*:*:*:*:*' menu select

# enable fuzzy matching for typos
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# case, hyphen and underscore insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

# complete . and .. special directories
zstyle ':completion:*' special-dirs true

# use cache
: ${ZSH_CACHE_DIR:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p "$ZSH_CACHE_DIR"
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$ZSH_CACHE_DIR"

# complete SSH hosts from ~/.ssh/config
if [[ -e ~/.ssh/config ]]; then
  zstyle ':completion:*:*:ssh:*' hosts "$(awk '/^Host / {print $2}' ~/.ssh/config | grep -v '[*?]')"
fi

# show colors on completion suggestions
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# fzf completions and key bindings
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
