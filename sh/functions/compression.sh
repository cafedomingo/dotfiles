#!/usr/bin/env sh

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
function 7zm_contents() {
  for entry in ./*; do
    7zm $entry
  done
}

# individually compress each file/directory in the current directory into it's own archive using zip
function zip_contents() {
  local cmd=(
    zip
    -9                      # maximum compression
    -r                      # recurse into directories
    --exclude="*.DS_Store"  # exclude .DS_Store files
  )

  for entry in ./*; do
    local filename=$(basename $entry)
    ${cmd[@]} "$filename.zip" "$filename"
  done
}
