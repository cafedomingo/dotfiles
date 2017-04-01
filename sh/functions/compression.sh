#!/usr/bin/env sh

# extracts archived files / mounts disk images
# credit: https://raw.githubusercontent.com/holman/dotfiles/master/functions/extract & http://nparikh.org/notes/zshrc.txt
function extract() {
  if [ -f $1 ]; then
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
  else
    echo "'$1' is not a valid file" && return 1
  fi
}

# compress the given file or directory using 7z "ultra settings"
function 7zm() {
  [ -z $1 ] || [ ! -e $1 ] && echo 'specify a file or directory to compress' && return 1

  local location=$(dirname $1)
  local filename=$(basename $1)

  local cmd=(
    # 7za is a stand-alone executable.
    # 7za handles less archive formats than 7z, but does not need any others.
    7za
    a                 # add/create
    -t7z              # 7z archive
    -m0=lzma          # lzma method
    -mx=9             # level of compression = 9 (Ultra)
    -mfb=64           # number of fast bytes for LZMA = 64
    -md=32m           # dictionary size = 32 megabytes
    -ms=on            # solid archive = on
    '-xr!*.DS_Store'  # exclude .DS_Store files
  )

  ${cmd[@]} "$location/$filename.7z" "$1"
}

# individually compress each file/directory in the current directory into it's own archive using 7z "ultra settings"
function 7zm_cwd() {
  for entry in ./*; do
    7zm $entry
  done
}

# compress the given file or directory using rar max compression
function rar5() {
  [ -z $1 ] || [ ! -e $1 ] && echo 'specify a file or directory to compress' && return 1

  local location=$(dirname $1)
  local filename=$(basename $1)

  local cmd=(
    rar
    a                 # add/create
    -s                # solid archive
    -m5               # max compression
    -md64             # 64mb dictionary
    -ma5              # rar 5.x formar
    '-x!*.DS_Store'   # exclude .DS_Store files
  )

  ${cmd[@]} "$location/$filename.rar" "$1"
}

# individually compress each file/directory in the current directory into it's own archive using rar max compression
function rar5_cwd() {
  for entry in ./*; do
    rar5 $entry
  done
}

# compress the given file or directory using zip max compression
function z9() {
  [ -z $1 ] || [ ! -e $1 ] && echo 'specify a file or directory to compress' && return 1

  local location=$(dirname $1)
  local filename=$(basename $1)

  local cmd=(
    zip
    -9                      # maximum compression
    -r                      # recurse into directories
    --exclude='*.DS_Store'  # exclude .DS_Store files
  )

  ${cmd[@]} "$location/$filename.zip" "$1"
}

# individually compress each file/directory in the current directory into it's own archive using zip max compression
function z9_cwd() {
  for entry in ./*; do
    z9 $entry
  done
}
