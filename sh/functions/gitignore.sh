#!/usr/bin/env sh

# generate gitignore file from https://www.gitignore.io
# https://github.com/joeblau/gitignore.io
function gitignore() {
  curl -L -s https://www.gitignore.io/api/$@;
}
