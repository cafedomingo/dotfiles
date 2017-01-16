#!/usr/bin/env sh

# generate a random string of letters, digits and symbols and copy to clipboard
# $1: password length (default: 40)
function password()
{
  ! [ $# -eq 0 -o $# -eq 1 -a "$1" -eq "$1" ] 2>/dev/null && echo "$1 is not a valid length" && return 1

  local length=$([ -z $1 ] && echo 40 || echo $1)
  LC_ALL=C tr -dc "[:alnum:][:punct:]" < /dev/urandom | head -c $length | pbcopy
}
