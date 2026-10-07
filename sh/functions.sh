# load functions from the functions subdirectory
() {
  local file
  for file in "$(dirname "${(%):-%x}")"/functions/*.sh; do
    [[ -f $file && -s $file ]] && source "$file"
  done
}
