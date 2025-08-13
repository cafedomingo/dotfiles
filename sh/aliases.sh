#!/usr/bin/env sh

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
if command -v lsd > /dev/null; then
  alias lsd='lsd -l --icon never --group-dirs first'
  alias ls='lsd'
  alias lsize='lsd --sizesort'
  alias tree='lsd --tree'
  alias lt='tree'
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
alias grep='grep --color=auto'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS}'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# git
alias g='git'
alias gf='git fetch'
alias grb='git rebase'
alias gfrb='git fetch && git rebase'
alias gco='git checkout'

# ag
if command -v ag > /dev/null; then
  alias a='ag --noheading -S'
fi

# [en|de]coding
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote(sys.argv[1]))"'
alias urldecode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote(sys.argv[1]))"'

# allow sudo to use aliases
alias sudo='sudo '

# generate a random number
alias rand='od -An -N2 -i /dev/urandom | xargs'

# macOS
if [ "$(uname -s)" = "Darwin" ]; then
  # brew
  if command -v "brew" &> /dev/null; then
    alias bup='brew upgrade && brew cleanup'
    alias brews='brew list'
    alias casks='brew list --cask'
  fi

  # get current ip address
  alias ip='ipconfig getifaddr en0'

  # open
  alias o='open'
  alias oo='open .'

  # cpu brand string
  alias cpu='sysctl -n machdep.cpu.brand_string'

  # clear DNS cache
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

  # rebuild launch services database
  alias lsrebuild='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'

  # install xcode command line tools
  alias xcinstall='xcode-select --install'
fi
