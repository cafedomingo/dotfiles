# go up N directories (default 1)
up() {
  local d=""
  local limit="${1:-1}"

  for ((i = 1; i <= limit; i++)); do
    d="../${d}"
  done

  cd "${d}" || return
}
