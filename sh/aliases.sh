# ls
if ls --color &> /dev/null; then # GNU
  alias ls='ls --color -Fh'
else # macOS
  alias ls='ls -GFh'
fi
alias l='ls'
alias ll='ls -l'
alias la='l -A'
alias lr='ls -tR'
alias ltime='ls -ltm'
alias ldot='ls -ld .*'
alias lsize='ls -1Ss'

# lsd
if has lsd; then
  alias lsd='lsd -l --icon never --group-dirs first'
  alias ls='lsd'
  alias lsize='lsd --sizesort'
  if has tree; then
    alias lt='tree'
  else
    alias tree='lsd --tree'
    alias lt='tree'
  fi
fi

# files/directories
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir="mkdir -p"

# history
alias h='history'
alias hgrep='fc -El 0 | grep'

# diff
#alias diff='diff --color=auto'

# du
alias dud='du -d 1 -h'
alias duf='du -sh *'

# find
alias fd='find . -type d -name '
alias ff='find . -type f -name '

# grep
if echo test | grep --color=auto test >/dev/null 2>&1; then
  alias grep='grep --color=auto'
  alias fgrep='grep -F --color=auto'
  alias egrep='grep -E --color=auto'
else
  alias fgrep='grep -F'
  alias egrep='grep -E'
fi
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS}'

# git
alias g='git'
alias gf='git fetch'
alias grb='git rebase'
alias gfrb='git fetch && git rebase'
alias gco='git checkout'

# ripgrep (rg)
if has rg; then
  alias rg='rg --smart-case'
  alias a='rg --no-heading --smart-case'
  alias rgc='rg --context 3'
  alias rgjs='rg --type js'
  alias rgpy='rg --type py'
  alias rgjson='rg --type json'
  alias rga='rg --no-ignore --hidden'
fi

# fzf
if has fzf; then
  alias fv='fzf --preview "bat --color=always --style=header,grid --line-range :300 {}" | xargs -r $EDITOR'
  alias fp='fzf --preview "bat --color=always --style=header,grid --line-range :300 {}"'
  alias fd='cd "$(find . -type d 2>/dev/null | fzf)"'
  alias fgl='git log --oneline --color=always | fzf --ansi --preview "git show --color=always {1}" | cut -d" " -f1 | xargs -r git show'
  alias fgb='git branch -a | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf | xargs -r git checkout'
  alias fkill='ps aux | fzf --header-lines=1 | awk "{print \$2}" | xargs -r kill'
  alias frg='rg --line-number --no-heading --color=always --smart-case . | fzf --ansi --delimiter : --preview "bat --color=always --highlight-line {2} {1}" | cut -d: -f1 | xargs -r $EDITOR'
fi

# bat
if has bat; then
  alias batn='bat --style=numbers'
  alias cat='bat --paging=never'
  alias ccat='bat --plain --paging=never'
  alias less='bat --paging=always'
fi

# allow sudo to use aliases
alias sudo='sudo '

# generate a random number
alias rand='od -An -N2 -i /dev/urandom | xargs'

# macOS
if is_macos; then
  # brew
  if has brew; then
    alias bup='brew upgrade && brew cleanup'
    alias brews='brew list'
    alias casks='brew list --cask'
  fi

  # get current ip address
  alias ip='ipconfig getifaddr en0'

  # open
  alias o='open'
  alias oo='open .'

  # clear DNS cache
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

  # rebuild launch services database
  alias lsrebuild='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'

  # install xcode command line tools
  alias xcinstall='xcode-select --install'
fi
