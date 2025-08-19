# extracts archived files / mounts disk images
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
    *.bz2)             bunzip2 "$1"  ;;
    *.dmg)             hdiutil mount "$1" ;;
    *.gz)              if command -v unpigz >/dev/null 2>&1; then unpigz "$1"; else gunzip "$1"; fi ;;
    *.lz)              lzip -d "$1" ;;
    *.rar)             unrar x "$1" ;;
    *.tar)             tar -xvf "$1" ;;
    *.tar.bz2|*.tbz2)  tar -jxvf "$1" ;;
    *.tar.gz|*.tgz)    if command -v unpigz >/dev/null 2>&1; then tar --use-compress-program=unpigz -xvf "$1"; else tar -zxvf "$1"; fi ;;
    *.tar.lz|*.tlz)    tar --lzip -xvf "$1" ;;
    *.tar.xz|*.txz)    tar -Jxvf "$1" ;;
    *.tar.zst)         tar --zstd -xvf "$1" ;;
    *.xz)              unxz "$1" ;;
    *.zst)             zstd -d "$1" ;;
    *.Z)               uncompress "$1" ;;
    *.zip|*.ZIP)       unzip "$1"  ;;
    *)                 echo "'$1' cannot be extracted/mounted" && return 1;;
  esac
}

# helper function for bulk compression
_compress_all() {
  local format="$1"        # zip, 7z, rar, tar.xz
  shift

  # auto-detect command names based on format
  local base_name="$format"
  case "$format" in
    tar.*) base_name="${format#tar.}" ;;  # tar.xz -> xz
  esac
  local max_cmd="${base_name}-max"
  local fast_cmd="${base_name}-fast"

  local cmd="$max_cmd"
  [ "$1" = "-f" ] && cmd="$fast_cmd" && shift

  local count=0
  for file in ./*; do
    [ -e "$file" ] || continue
    case "$file" in
      *.7z|*.bz2|*.gz|*.lz|*.rar|*.tar|*.tar.bz2|*.tar.gz|*.tar.lz|*.tar.xz|*.tar.zst|*.tbz2|*.tgz|*.tlz|*.txz|*.xz|*.zst|*.Z|*.zip)
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
if command -v 7za >/dev/null 2>&1; then
  function 7z-max() { 7za a -t7z -mx=9 -mfb=64 -md=32m -ms=on -mmt "$@"; }
  function 7z-fast() { 7za a -t7z -mx=6 -md=16m -ms=on -mmt "$@"; }
  function 7z-all() { _compress_all "7z" "$@"; }
fi

if command -v pigz >/dev/null 2>&1; then
  function gz-max() { tar -cf - "$1" | pigz -9 -R > "$1.tar.gz"; }
  function gz-fast() { tar -cf - "$1" | pigz -6 -R > "$1.tar.gz"; }
  function gz-all() { _compress_all "tar.gz" "$@"; }
fi

if command -v xz >/dev/null 2>&1; then
  function xz-max() { tar -cf - "$1" | xz -9 -e -T0 > "$1.tar.xz"; }
  function xz-fast() { tar -cf - "$1" | xz -6 -T0 > "$1.tar.xz"; }
  function xz-all() { _compress_all "tar.xz" "$@"; }
fi

if command -v zip >/dev/null 2>&1; then
  function zip-max() { zip -9 -r "$@"; }
  function zip-fast() { zip -6 -r "$@"; }
  function zip-all() { _compress_all "zip" "$@"; }
fi
