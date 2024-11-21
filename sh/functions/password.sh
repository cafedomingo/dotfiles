#!/usr/bin/env sh

# generate a random string of letters, digits and symbols and copy to clipboard
password()
{
  local usage="\
Usage: password [-s] [-n length]
Options:
  -s      exclude symbols/punctuation
  -n=NUM  specify password length"
  local length=40
  local chars="A-Za-z0-9!@#$%^&*()_+-=[]{}|;:,.<>?~"

  while getopts n:s opt; do
     case "$opt" in
        n) length=$OPTARG               ;;
        s) chars=${chars%"[:punct:]"}   ;;
        *) echo "$usage" && return 1    ;;
     esac
  done

  if ! [[ "$length" =~ ^[0-9]+$ ]] || [ "$length" -lt 1 ]; then
    echo "error: invalid length" && return 1
  fi

  LC_ALL=C tr -dc "$chars" < /dev/urandom | head -c "$length" | pbcopy
}
