# extracts archived files / mounts disk images
# credit: http://nparikh.org/notes/zshrc.txt
extract() {
  local usage="\
Usage: extract <file>
Extract various archive formats including zip, tar, 7z, rar, etc."

  if [ -z "$1" ]; then
    echo "$usage"
    return 1
  fi

  [ ! -f "$1" ] && echo "'$1' is not a valid file" && return 1

  case $1 in
    *.7z)              7za x "$1"   ;;
    *.tar.bz2|*.tbz2)  tar -jxvf "$1" ;;
    *.tar.gz|*.tgz)    tar -zxvf "$1" ;;
    *.bz2)             bunzip2 "$1"  ;;
    *.dmg)             hdiutil mount "$1" ;;
    *.gz)              gunzip "$1"   ;;
    *.tar)             tar -xvf "$1" ;;
    *.zip|*.ZIP)       unzip "$1"  ;;
    *.rar)             unrar x "$1" ;;
    *.Z)               uncompress "$1" ;;
    *)                 echo "'$1' cannot be extracted/mounted" && return 1;;
  esac
}

# helper function for bulk compression
_compress_all() {
  local format="$1"        # zip, 7z, rar
  local max_cmd="$2"       # zip-max, 7z-max, rar-max
  local fast_cmd="$3"      # zip-fast, 7z-fast, rar-fast
  shift 3

  local cmd="$max_cmd"
  [ "$1" = "-f" ] && cmd="$fast_cmd" && shift

  local count=0
  for file in ./*; do
    [ -e "$file" ] || continue
    case "$file" in
      *.zip|*.7z|*.rar|*.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar|*.bz2|*.gz|*.Z)
        echo "Skipping already compressed: $(basename "$file")"
        ;;
      *)
        echo "Compressing $(basename "$file")..."
        $cmd "$(basename "$file").$format" "$file" && ((count++))
        ;;
    esac
  done
  echo "Compressed $count files"
}

# compression functions
if command -v zip >/dev/null 2>&1; then
  function zip-max() { zip -9 -r "$@"; }
  function zip-fast() { zip -6 -r "$@"; }
  function zip-all() { _compress_all "zip" "zip-max" "zip-fast" "$@"; }
fi

if command -v 7za >/dev/null 2>&1; then
  function 7z-max() { 7za a -t7z -mx=9 -mfb=64 -md=32m -ms=on "$@"; }
  function 7z-fast() { 7za a -t7z -mx=6 -md=16m -ms=on "$@"; }
  function 7z-all() { _compress_all "7z" "7z-max" "7z-fast" "$@"; }
fi

if command -v rar >/dev/null 2>&1; then
  function rar-max() { rar a -s -m5 -md64 -ma5 "$@"; }
  function rar-fast() { rar a -m3 -md32 "$@"; }
  function rar-all() { _compress_all "rar" "rar-max" "rar-fast" "$@"; }
fi
