#!/usr/bin/env sh

# generate gitignore file from https://www.toptal.com/developers/gitignore/
gi() {
  curl -sL "https://www.toptal.com/developers/gitignore/api/$*"
}
