[[ -s ~/.sh/env.sh ]] && source ~/.sh/env.sh
[[ -s ~/.env.local ]] && source ~/.env.local

# set HOMEBREW_PREFIX and update PATH/MANPATH/INFOPATH/fpath
if (( $+commands[brew] )); then
  eval "$(brew shellenv)"
fi
