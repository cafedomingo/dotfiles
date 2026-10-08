[[ -s ~/.sh/env.zsh ]] && source ~/.sh/env.zsh
[[ -s ~/.env.local ]] && source ~/.env.local

# set HOMEBREW_PREFIX and update PATH/MANPATH/INFOPATH/fpath
if (( $+commands[brew] )); then
  eval "$(brew shellenv)"
fi
