# ls
if ls --color >/dev/null 2>&1; then # GNU
  alias ls='ls --color=auto -Fh'
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

# eza
if (($+commands[eza])); then
  alias ll='eza -l --git --group-directories-first'
  alias ls='ll'
  alias lsize='eza -l -s size -r' # -r keeps largest first
  alias lr='eza -R -s age'
  alias ltime='eza -l -s age'
  if (($+commands[tree])); then
    alias lt='tree'
  else
    alias tree='eza -T'
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

# diff
#alias diff='diff --color=auto'

# du
alias dud='du -d 1 -h'
alias duf='du -sh *'

# find
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
alias gco='git checkout'
alias gf='git fetch'
alias gfrb='git fetch && git rebase'
alias grb='git rebase'
alias gs='git status'

# ripgrep (rg)
if (($+commands[rg])); then
  alias rg='rg --smart-case'
  alias a='rg --no-heading --smart-case'
  alias rgc='rg --context 3'
  alias rgjs='rg --type js'
  alias rgpy='rg --type py'
  alias rgjson='rg --type json'
  alias rga='rg --no-ignore --hidden'
fi

# fzf
if (($+commands[fzf])); then
  alias fp='fzf --preview "bat --color=always --style=header,grid --line-range :300 {}"'
  alias fd='cd "$(find . -type d 2>/dev/null | fzf)"'
  fv() {
    local file
    file=$(fzf --preview "bat --color=always --style=header,grid --line-range :300 {}")
    [[ -n "$file" ]] && ${EDITOR} "$file"
  }
  fgl() {
    local hash
    hash=$(git log --oneline --color=always | fzf --ansi --preview "git show --color=always {1}" | cut -d" " -f1)
    [[ -n "$hash" ]] && git show "$hash"
  }
  fgb() {
    local branch
    branch=$(git branch -a | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf)
    [[ -n "$branch" ]] && git checkout "$branch"
  }
  fkill() {
    local pid
    pid=$(ps aux | fzf --header-lines=1 | awk '{print $2}')
    [[ -n "$pid" ]] && kill "$pid"
  }
  frg() {
    local file
    file=$(rg --line-number --no-heading --color=always --smart-case . | fzf --ansi --delimiter : --preview "bat --color=always --highlight-line {2} {1}" | cut -d: -f1)
    [[ -n "$file" ]] && ${EDITOR} "$file"
  }
fi

# bat
if (($+commands[bat])); then
  alias batn='bat --style=numbers'
  alias cat='bat --plain'
  alias less='bat --paging=always'
fi

# claude
if [[ -f ~/.claude/settings.local.json ]]; then
  alias claude='claude --settings ~/.claude/settings.local.json'
fi
alias cc='claude'

# allow sudo to use aliases
alias sudo='sudo '

# generate a random number
alias rand='od -An -N2 -i /dev/urandom | xargs'

# macOS
if [[ $OSTYPE == darwin* ]]; then
  # brew
  if (($+commands[brew])); then
    alias bup='brew upgrade --yes && brew cleanup -s'
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

  # quick look
  ql() { qlmanage -p "$@" >/dev/null 2>&1; }

  # volume
  alias mute='osascript -e "set volume output muted true"'
  alias unmute='osascript -e "set volume output muted false"'
fi

# help
alias help='run-help'

# navigation
alias -- -='cd -'
alias -g ...='../..'
alias -g ....='../../..'

# global aliases for common pipes and redirections
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g N="&> /dev/null"

# archive viewers (using unified als function)
alias -s 7z='als'
alias -s rar='als'
alias -s tar='als'
alias -s taz='als'
alias -s tbz='als'
alias -s tbz2='als'
alias -s tgz='als'
alias -s txz='als'
alias -s zip='als'
