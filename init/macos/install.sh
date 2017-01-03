#!/usr/bin/env sh

source ../util.sh

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
if ! has_homebrew; then
  printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
  # └─ simulate the ENTER keypress
else
  brew update &> /dev/null
  brew upgrade &> /dev/null
fi;

##########
# homebrew cask
# └─ https://caskroom.github.io
##########
if ! brew cask > /dev/null; then
  brew install caskroom/cask/brew-cask
fi;

##########
# install shells (via homebrew)
##########
brew tap homebrew/versions      # https://github.com/Homebrew/homebrew-versions
brew tap homebrew/completions   # https://github.com/Homebrew/homebrew-completions

shells=(
  bash
  fish
  zsh
)

for shell in ${shells[@]}; do
  brew install $shell
  # add shells to system
  if ! fgrep -q $(brew --prefix)/bin/$shell /etc/shells; then
    echo $(brew --prefix)/bin/$shell | sudo tee -a /etc/shells > /dev/null;
  fi;
done

completions=(
  bash-completion2
  brew-cask-completion
  gem-completion
  launchctl-completion
  rake-completion
)

for completion in "${completions[@]}"; do
  brew install $completions
done

##########
# install fonts (via homebrew)
##########
brew tap caskroom/fonts   # https://github.com/caskroom/homebrew-fonts

fonts=(
  font-droid-sans
  font-droid-sans-mono
  font-droid-serif
  font-hack
  font-roboto
  font-roboto-condensed
  font-roboto-mono
  font-roboto-slab
)

for font in "${fonts[@]}"; do
  brew cask install $font
done

# sf mono - https://medium.com/@deepak.gulati/using-sf-mono-in-emacs-6712c45b2a6d
if [[ -d /Applications/Utilities/Terminal.app/Contents/Resources/Fonts ]]; then
  open /Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SFMono-*
fi;

# sf ui & sf compact - https://developer.apple.com/fonts/
if [[ -d ~/Dropbox/Fonts/SF* ]]; then
  open ~/Dropbox/Fonts/SF-UI*/*
  open ~/Dropbox/Fonts/SF-Compact*/*
fi;

##########
# install cli apps
##########
formulas=(
  # updated system tools
  coreutils # GNU core utilities
  findutils # GNU `find`, `locate`, `updatedb`, `xargs`, and `g`-prefixed
  moreutils # other useful utilities like `sponge`
  homebrew/dupes/openssh
  'vim --with-override-system-vi'

  css-crush
  exif
  gifsicle
  git
  gpg2
  homebrew/dupes/openssh
  htmlcompressor
  htop
  httpie
  jpegoptim
  jq
  node
  optipng
  p7zip
  pngcrush
  unrar
  wifi-password
  'wget --with-iri'
)

for formula in "${formulas[@]}"; do
  brew install $formula
done

##########
# install gui apps
##########
brew tap caskroom/versions  # https://github.com/caskroom/homebrew-versions

apps=(
  1password
  aerial
  alfred
  android-studio
  applepi-baker
  atom
  boxer
  brave
  charles
  dropbox
  firefox
  flux
  garmin-express
  google-chrome
  imageoptim
  iterm2
  kaleidoscope
  microsoft-office
  openemu
  opera
  paw
  safari-technology-preview
  sketch
  sublime-text
  transmission
  transmit
  visual-studio
  vlc
)

for app in "${apps[@]}"; do
  brew cask install $app
done

##########
# cleanup
##########
brew cleanup
