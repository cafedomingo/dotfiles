#!/usr/bin/env sh

# extracts archived files / mounts disk images
# credit: https://raw.githubusercontent.com/holman/dotfiles/master/functions/extract & http://nparikh.org/notes/zshrc.txt
function extract() {
  local usage="\
Usage: extract <file>"

  [ -f $1 ] && echo "'$1' is not a valid file" && return 1

  case $1 in
    *.7z)       7za x $1                            ;;
    *.tar.bz2)  tar -jxvf $1                        ;;
    *.tar.bz2)  tar -jxvf $1                        ;;
    *.tar.gz)   tar -zxvf $1                        ;;
    *.bz2)      bunzip2 $1                          ;;
    *.dmg)      hdiutil mount $1                    ;;
    *.gz)       gunzip $1                           ;;
    *.tar)      tar -xvf $1                         ;;
    *.tbz2)     tar -jxvf $1                        ;;
    *.tgz)      tar -zxvf $1                        ;;
    *.zip)      unzip $1                            ;;
    *.ZIP)      unzip $1                            ;;
    *.pax)      cat $1 | pax -r                     ;;
    *.pax.Z)    uncompress $1 --stdout | pax -r     ;;
    *.rar)      unrar x $1                          ;;
    *.Z)        uncompress $1                       ;;
    *)          echo "'$1' cannot be extracted/mounted" && return 1;;
  esac
}

# compress target file or directory using one of multiple compression options
function shrink() {
  local usage="\
Usage: shrink [-7 | -r | -z] (<file> | <directory>)
Options:
  -7    compress using 7-zip
  -r    compress using rar
  -z    compress using zip (default)"
  local z7=(
    7za
    a                       # add/create
    -t7z                    # 7z archive
    -m0=lzma                # lzma method
    -mx=9                   # level of compression = 9 (Ultra)
    -mfb=64                 # number of fast bytes for LZMA = 64
    -md=32m                 # dictionary size = 32 megabytes
    -ms=on                  # solid archive = on
    '-xr!*.DS_Store'        # exclude .DS_Store files
  )
  local rar=(
    rar
    a                       # add/create
    -s                      # solid archive
    -m5                     # max compression
    -md64                   # 64mb dictionary
    -ma5                    # rar 5.x formar
    '-x!*.DS_Store'         # exclude .DS_Store files
  )
  local zip=(
    zip
    -9                      # maximum compression
    -r                      # recurse into directories
    --exclude='*.DS_Store'  # exclude .DS_Store files
  )

  local cmd=("${zip[@]}")
  local extension='7z'

  while getopts 7rzh opt
  do
     case $opt in
        7) extension='7z'   &&  cmd=("${z7[@]}")    ;;
        r) extension='rar'  &&  cmd=("${rar[@]}")   ;;
        z) extension='zip'  &&  cmd=("${zip[@]}")   ;;
        *) echo $usage && return 1                  ;;
     esac
  done

  # validate target file or directory
  local target=$@[$OPTIND]
  [ -z $target ] || [ ! -e $target ] && echo "'$target' is not a valid file or directory" && return 1

  local location=$(dirname $target)
  local filename=$(basename $target)

  ${cmd[@]} "$location/$filename.$extension" "$target"
}

# individually compress each file/directory in the current directory
function shrink_cwd() {
  for entry in ./*; do
    shrink $@ $entry
  done
}
