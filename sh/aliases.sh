#!/usr/bin/env sh

# ls
if ls --color &> /dev/null; then # GNU
  alias ls="ls --color"
else # macOS
  alias ls="ls --G"
fi
alias l='ls -lFh'
alias la='ls -lAFh'
alias lr='ls -tRFh'
alias lt='ls -ltFh'
alias ll='ls -l'
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'

# files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# du
alias dud='du -d 1 -h'
alias duf='du -sh *'

# find
alias fd='find . -type d -name'
alias ff='find . -type f -name'

# grep
alias grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS}'

# history
alias h='history'
alias hgrep='fc -El 0 | grep'

# mkdir
alias mkdir="mkdir -p"

# bundler
alias be='bundle exec'
alias bi='bundle install'
alias bu='bundle update'

# cocoapods
alias pi='pod install'
alias pu='pod update'

# [en|de]coding
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])"'
alias urldecode='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])"'

# allow sudo to use aliases
alias sudo='sudo '

# get current ip address
alias ip='ipconfig getifaddr en0'

# generate a random number
alias rand='od -An -N2 -i /dev/urandom | xargs'

# macOS
if [[ is_macos ]]; then
  # brew
  if [[ has_homebrew ]]; then
    alias cask='brew cask'
    alias bup='brew update; brew upgrade; brew cleanup'
  fi

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
