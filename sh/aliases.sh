#!/usr/bin/env sh

# ls
alias ls='ls --color=auto -Fh'
alias l='ls'
alias ll='ls -l'
alias la='l -A'
alias lr='ls -tR'
alias ltime='ls -ltm'
alias ldot='ls -ld .*'
alias lsize='ls -1Ss'

# lsd
if command -v lsd > /dev/null; then
  alias lsd='lsd -l --group-dirs first'
  alias ls='lsd -l'
  alias lsize='lsd --sizesort'
  alias tree='lsd --tree'
  alias lt='tree'
fi

# files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# diff
#alias diff='diff --color=auto'

# du
alias dud='du -d 1 -h'
alias duf='du -sh *'

# find
alias fd='find . -type d -name'
alias ff='find . -type f -name'

# grep
alias grep='grep --color=auto'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS}'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ag
alias a='ag --noheading -S'

# history
alias h='history'
alias hgrep='fc -El 0 | grep'

# mkdir
alias mkdir="mkdir -p"

# bundler
alias be='bundle exec'
alias bi='bundle install'
alias bu='bundle update'

# [en|de]coding
alias urlencode='python -c "import sys, urllib as ul; print ul.quote(sys.argv[1])"'
alias urldecode='python -c "import sys, urllib as ul; print ul.unquote(sys.argv[1])"'

# allow sudo to use aliases
alias sudo='sudo '

# generate a random number
alias rand='od -An -N2 -i /dev/urandom | xargs'

# macOS
if [ $(uname -s) = "Darwin" ]; then
  # brew
  if command -v "brew" &> /dev/null; then
    alias cask='brew cask'
    alias bup='brew upgrade; brew cleanup'
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

  # SSID for current wi-fi network
  alias wifi='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '\''/ SSID/ {print substr($0, index($0, $2))}'\'

  # install xcode command line tools
  alias xcinstall='xcode-select --install'
fi
