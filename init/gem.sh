#!/usr/bin/env sh

# install command-line tools using gem

gem install bundler
gem install rake

if is_macos; then
  gem install cocoapods
fi
