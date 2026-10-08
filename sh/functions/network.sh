# check what's using a port
port() {
  if [[ $OSTYPE == darwin* ]]; then
    lsof -iTCP:"$1" -sTCP:LISTEN
  else
    ss -tlnp "sport = :$1"
  fi
}
