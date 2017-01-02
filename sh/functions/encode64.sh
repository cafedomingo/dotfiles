#!/usr/bin/env sh

# [en|de]code to base64
# taken from encode64 zsh plugin: https://github.com/robbyrussell/oh-my-zsh/blob/7daa207dbc92afc9bf1ea5bc41ff3e7611409f52/plugins/encode64/encode64.plugin.zsh

encode64() {
    if [[ $# -eq 0 ]]; then
        cat | base64
    else
        printf '%s' $1 | base64
    fi
}

decode64() {
    if [[ $# -eq 0 ]]; then
        cat | base64 --decode
    else
        printf '%s' $1 | base64 --decode
    fi
}
