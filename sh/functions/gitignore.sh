#!/usr/bin/env sh

# generate gitignore file from https://www.gitignore.io
# https://github.com/joeblau/gitignore.io
gi() {
  curl -sL "https://www.gitignore.io/api/$*"
}
