# generate a random string of letters, digits and optionally symbols; copy to clipboard if available
password() {
  local usage length=40 use_punct=1 charset opt OPTARG
  usage="Usage: password [-s] [-n NUM]
Options:
  -s       exclude symbols/punctuation (use alnum only)
  -n NUM   specify password length (default 40)"

  while getopts "n:s" opt; do
    case "$opt" in
      n) length=$OPTARG ;;
      s) use_punct=0 ;;
      *) printf '%s\n' "$usage" >&2; return 1 ;;
    esac
  done
  shift $((OPTIND - 1))
  if [[ $# -gt 0 ]]; then
    printf '%s\n' "$usage" >&2; return 1
  fi

  case $length in
    ''|*[!0-9]*) printf 'error: invalid length\n' >&2; return 1 ;;
  esac
  if [[ "$length" -lt 1 ]]; then
    printf 'error: invalid length\n' >&2; return 1
  fi

  if [[ "$use_punct" -eq 1 ]]; then
    charset='[:alnum:][:punct:]'
  else
    charset='[:alnum:]'
  fi

  if (( $+commands[pbcopy] )); then
    LC_ALL=C tr -dc "$charset" < /dev/urandom | head -c "$length" | pbcopy
  else
    LC_ALL=C tr -dc "$charset" < /dev/urandom | head -c "$length"
  fi
}
