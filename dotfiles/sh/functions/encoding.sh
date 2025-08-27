# base64 encoding/decoding
encode64() {
  printf '%s' "${1:-$(cat)}" | base64
}

decode64() {
  if base64 --decode </dev/null >/dev/null 2>&1; then
    opt='--decode'
  elif base64 -d </dev/null >/dev/null 2>&1; then
    opt='-d'
  else
    opt='-D'
  fi
  printf '%s' "${1:-$(cat)}" | base64 "$opt"
}

# url encoding/decoding
urlencode() {
  printf '%s' "${1:-$(cat)}" | python3 -c "import sys, urllib.parse as ul; print(ul.quote(sys.stdin.read().strip()))"
}

urldecode() {
  printf '%s' "${1:-$(cat)}" | python3 -c "import sys, urllib.parse as ul; print(ul.unquote(sys.stdin.read().strip()))"
}

# hexadecimal encoding/decoding (text/binary data)
hexencode() {
  printf '%s' "${1:-$(cat)}" | xxd -p | tr -d '\n'
}

hexdecode() {
  printf '%s' "${1:-$(cat)}" | xxd -r -p
}

# numeric base conversion (decimal ⟷ hexadecimal)
dec2hex() {
  printf '%x\n' "${1:-$(cat)}"
}

hex2dec() {
  printf '%d\n' "$((16#${1:-$(cat)}))"
}

# numeric base conversion (decimal ⟷ binary)
dec2bin() {
  printf '%s\n' "obase=2; ${1:-$(cat)}" | bc
}

bin2dec() {
  printf '%d\n' "$((2#${1:-$(cat)}))"
}
