#!/usr/bin/env sh

# generate a random string of letters, digits and symbols and copy to clipboard
function password()
{
  local usage="\
Usage: password [-s] [-n length]
Options:
  -s      exclude symbols/punctuation
  -n=NUM  specify password length"
  local length=40
  local chars="[:alnum:][:punct:]"

  while getopts n:s opt
  do
     case "$opt" in
        n) length=$OPTARG               ;;
        s) chars=${chars%"[:punct:]"}   ;;
        *) echo $usage && return 1      ;;
     esac
  done

  ! [ "$length" -eq "$length" ] 2>/dev/null && echo "error: $length is not a valid length" && return 1
  [ $length -lt 1 ] && echo "error: length must be greater than 0" && return 1

  LC_ALL=C tr -dc "$chars" < /dev/urandom | head -c $length | pbcopy
}
