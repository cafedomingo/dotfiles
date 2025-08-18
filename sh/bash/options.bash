# keep history up to date, across sessions, in realtime
# http://unix.stackexchange.com/a/48113
HISTCONTROL=ignoredups:erasedups
HISTSIZE=100000
HISTFILESIZE=$HISTSIZE
HISTIGNORE='&:ls:[bf]g:exit:history'

# enable history appending and immediate sharing between sessions
shopt -s histappend 2>/dev/null

if [[ -t 1 ]]; then
    # Set tab title to current directory
    set_tab_title() {
        echo -ne "\e]1;${PWD/#$HOME/~}\a"
    }

    # Add tab title update to PROMPT_COMMAND
    PROMPT_COMMAND="history -a; history -c; history -r; set_tab_title; ${PROMPT_COMMAND:-}"
fi
