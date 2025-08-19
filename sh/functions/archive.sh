# list archive contents
als() {
  local file="$1"

  if [ -z "$file" ]; then
    echo "Usage: als <file>"
    return 1
  fi

  if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found" >&2
    return 1
  fi

  case "$file" in
    *.tar.gz|*.tgz)     command tar -tzf "$file" ;;
    *.tar.bz2|*.tbz|*.tbz2) command tar -tjf "$file" ;;
    *.tar.xz|*.txz)     command tar -tJf "$file" ;;
    *.tar.zst)          command tar --zstd -tf "$file" ;;
    *.tar.lz|*.tlz)     command tar --lzip -tf "$file" ;;
    *.tar.Z|*.taz)      command tar -tZf "$file" ;;
    *.tar)              command tar -tf "$file" ;;
    *.7z)               command 7za l "$file" ;;
    *.zip|*.ZIP)        command unzip -l "$file" ;;
    *.rar)              command unrar l "$file" ;;
    *.bz2)              command bzip2 -tv "$file" ;;
    *.gz)               command gzip -l "$file" ;;
    *.xz)               command xz -l "$file" ;;
    *.zst)              command zstd -l "$file" ;;
    *.lz)               command lzip -l "$file" ;;
    *.Z)                command uncompress -l "$file" 2>/dev/null || command gzip -l "$file" ;;
    *)                  echo "Unsupported format: $file" >&2; return 1 ;;
  esac
}

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
    *.7z)              command 7za x "$1"   ;;
    *.bz2)             command bunzip2 "$1"  ;;
    *.dmg)             hdiutil mount "$1" ;;
    *.gz)              if command -v unpigz >/dev/null 2>&1; then command unpigz "$1"; else command gunzip "$1"; fi ;;
    *.lz)              command lzip -d "$1" ;;
    *.rar)             command unrar x "$1" ;;
    *.tar)             command tar -xvf "$1" ;;
    *.tar.bz2|*.tbz2)  command tar -jxvf "$1" ;;
    *.tar.gz|*.tgz)    if command -v unpigz >/dev/null 2>&1; then command tar --use-compress-program=unpigz -xvf "$1"; else command tar -zxvf "$1"; fi ;;
    *.tar.lz|*.tlz)    command tar --lzip -xvf "$1" ;;
    *.tar.xz|*.txz)    command tar -Jxvf "$1" ;;
    *.tar.zst)         command tar --zstd -xvf "$1" ;;
    *.xz)              command unxz "$1" ;;
    *.zst)             command zstd -d "$1" ;;
    *.Z)               command uncompress "$1" ;;
    *.zip|*.ZIP)       command unzip "$1"  ;;
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

  local use_fast=false
  [ "$1" = "-f" ] && use_fast=true && shift

  local count=0
  for file in ./*; do
    [ -e "$file" ] || continue
    case "$file" in
      *.7z|*.bz2|*.gz|*.lz|*.rar|*.tar|*.tar.bz2|*.tar.gz|*.tar.lz|*.tar.xz|*.tar.zst|*.tbz2|*.tgz|*.tlz|*.txz|*.xz|*.zst|*.Z|*.zip)
        echo "Skipping already compressed: $(basename "$file")"
        ;;
      *)
        echo "Compressing $(basename "$file")..."
        if [ "$use_fast" = true ]; then
          # use fast compression (leverages aliases)
          case "$format" in
            7z)      7za a -t7z "$(basename "$file").$format" "$file" ;;
            tar.gz)  if command -v pigz >/dev/null 2>&1; then
                       tar -cf - "$file" | pigz > "$(basename "$file").$format"
                     else
                       tar -cf - "$file" | gzip -6 > "$(basename "$file").$format"
                     fi ;;
            tar.xz)  tar -cf - "$file" | xz > "$(basename "$file").$format" ;;
            zip)     zip "$(basename "$file").$format" "$file" ;;
            *)       echo "Fast compression not implemented for $format" >&2; continue ;;
          esac
        else
          # use max compression (default)
          "${base_name}-max" "$(basename "$file").$format" "$file"
        fi
        [ $? -eq 0 ] && ((count++))
        ;;
    esac
  done
  echo "Compressed $count files"
}

# fast compression with multi-threading by default
if command -v 7za >/dev/null 2>&1; then
  alias 7za='7za -mmt -mx=6 -md=16m -ms=on'
  function 7z-max() { command 7za a -t7z -mx=9 -mfb=64 -md=32m -ms=on -mmt "$@"; }
  function 7z-all() { _compress_all "7z" "$@"; }
fi

if command -v pigz >/dev/null 2>&1; then
  alias pigz='pigz -R -6'
  alias gz='pigz -R -6'
  function gz-max() { tar -cf - "$1" | command pigz -9 -R > "$1.tar.gz"; }
  function gz-all() { _compress_all "tar.gz" "$@"; }
elif command -v gzip >/dev/null 2>&1; then
  alias gz='gzip -6'
  function gz-max() { tar -cf - "$1" | command gzip -9 > "$1.tar.gz"; }
  function gz-all() { _compress_all "tar.gz" "$@"; }
fi

if command -v xz >/dev/null 2>&1; then
  alias xz='xz -T0 -6'
  function xz-max() { tar -cf - "$1" | command xz -9 -e -T0 > "$1.tar.xz"; }
  function xz-all() { _compress_all "tar.xz" "$@"; }
fi

if command -v zip >/dev/null 2>&1; then
  alias zip='zip -6 -r'
  function zip-max() { command zip -9 -r "$@"; }
  function zip-all() { _compress_all "zip" "$@"; }
fi
