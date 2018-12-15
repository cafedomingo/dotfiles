#!/usr/bin/env sh

# install command-line tools using gem

gems=(
  bundler
  rake
)

if is_macos; then
  gems+=(
    cocoapods
  )
fi

gem install "${gems[@]}"
