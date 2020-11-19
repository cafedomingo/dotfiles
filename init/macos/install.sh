#!/usr/bin/env sh

location=$(dirname "$([ -z "${BASH_SOURCE[0]}" ] && echo "${(%):-%x}" || echo "${BASH_SOURCE[0]}")")

##########
# xcode cli tools
# └─ https://developer.apple.com/download/more/
##########
xcode-select --install

##########
# java runtime
# └─ https://www.java.com/en/download/manual.jsp
##########
/usr/libexec/java_home --request

##########
# homebrew
# └─ http://brew.sh
##########
if [[ command -v "brew" &> /dev/null ]]; then
  brew update &> /dev/null
  brew upgrade &> /dev/null
else
  printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
  # └─ simulate the ENTER keypress
fi

##########
# homebrew cask
# └─ https://caskroom.github.io
##########
if ! brew cask > /dev/null; then
  brew install caskroom/cask/brew-cask
fi

##########
# setup taps
##########
brew tap caskroom/fonts         # https://github.com/caskroom/homebrew-fonts

##########
# install shells
##########
shells=(
  bash
  zsh
)

brew install "${shells[@]}"

for shell in "${shells[@]}"; do
  # add shells to system
  if ! grep -F -q "$(brew --prefix)/bin/$shell" /etc/shells; then
    echo "$(brew --prefix)/bin/$shell" | sudo tee -a /etc/shells > /dev/null
  fi
done

completions=(
  bash-completion2
  brew-cask-completion
  gem-completion
  launchctl-completion
  rake-completion
)

brew install "${completions[@]}"

##########
# install fonts
##########
fonts=(
  font-hack
  font-roboto
  font-roboto-condensed
  font-roboto-mono
  font-roboto-slab
)

brew cask install "${fonts[@]}"

# sf mono - https://medium.com/@deepak.gulati/using-sf-mono-in-emacs-6712c45b2a6d
if [ -d /Applications/Utilities/Terminal.app/Contents/Resources/Fonts ]; then
  open /Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SFMono-*
fi

# sf pro & sf compact - https://developer.apple.com/fonts/
for directory in ~/Dropbox/Fonts/SF*; do
  if [ -d "$directory" ]; then
    open "$directory"/*
  fi
done

##########
# install cli apps
##########
formulas=(
  # updated system tools
  coreutils # GNU core utilities
  findutils # GNU `find`, `locate`, `updatedb`, `xargs`, and `g`-prefixed
  moreutils # other useful utilities like `sponge`
  openssh
  'vim --with-override-system-vi'

  ag
  css-crush
  exif
  gifsicle
  git
  gpg2
  guetzli
  htmlcompressor
  htop
  httpie
  jpegoptim
  jq
  lsd
  mas
  nano
  node
  optipng
  p7zip
  pngcrush
  wifi-password
  wget
)

for formula in "${formulas[@]}"; do
  brew install "$formula"
done

##########
# install apps
##########
apps=(
  1password
  aerial
  alfred
  android-studio
  applepi-baker
  balenaetcher
  boxer
  charles
  dropbox
  firefox
  google-chrome
  imageoptim
  iterm2
  kaleidoscope
  microsoft-office
  openemu
  opera
  paw
  rar
  sublime-text
  transmission
  transmit
  visual-studio
  visual-studio-code
  vlc
)

for app in "${apps[@]}"; do
  brew cask install "$app"
done

##########
# cleanup
##########
brew cleanup
