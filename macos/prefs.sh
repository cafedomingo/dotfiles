#!/usr/bin/env bash

set -euo pipefail

# inspired by: https://mths.be/macos
# `defaults find` is good at finding some set preferences.

# close System Settings to prevent overriding settings
osascript -e 'tell application "System Settings" to quit'

# ask for the administrator password upfront
sudo -v

# keep-alive: update existing `sudo` time stamp until `prefs.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

### finder
# show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# show path bar
defaults write com.apple.finder ShowPathbar -bool true

# set sidebar icon size to small
defaults write Apple Global Domain NSTableViewDefaultSizeMode -int 1

# search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# set home as the default location for new windows
defaults write com.apple.finder NewWindowTarget -string 'PfHm'

# enable snap-to-grid for icons on the desktop and other icon views
defaults write com.apple.finder DesktopViewSettings -dict-add IconViewSettings -dict arrangeBy grid
defaults write com.apple.finder FK_StandardViewSettings -dict-add IconViewSettings -dict arrangeBy grid
defaults write com.apple.finder StandardViewSettings -dict-add IconViewSettings -dict arrangeBy grid

# use list view in all finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# show the ~/Library & /Volumes folders
chflags nohidden ~/Library
sudo chflags nohidden /Volumes

# expand file info panes
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  MetaData -bool true \
  OpenWith -bool true \
  Privileges -bool true

### desktop / dock
# dark mode
defaults write Apple Global Domain AppearancePreference -string Dark

# position the dock on the left
defaults write com.apple.dock orientation -string "left"

# set the icon size of Dock items to 32 pixels
defaults write com.apple.dock tilesize -int 32

# minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# enable app exposé gesture (swipe down with 3 fingers)
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# speed up animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float .5

# automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

### input
# check for trackpad before applying settings
if system_profiler SPBluetoothDataType | grep -q "Apple Trackpad"; then
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
fi

# use keyboard navigation to move focus between controls
defaults write Apple Global Domain AppleKeyboardUIMode -int 2

# set keyboard repeat rate
defaults write Apple Global Domain KeyRepeat -int 2
defaults write Apple Global Domain InitialKeyRepeat -int 25

# disable auto-capitalization
defaults write Apple Global Domain NSAutomaticCapitalizationEnabled -bool false

# disable auto-correct
defaults write Apple Global Domain NSAutomaticSpellingCorrectionEnabled -bool false

### misc
# disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# expand save panel by default
defaults write Apple Global Domain NSNavPanelExpandedStateForSaveMode -bool true
defaults write Apple Global Domain NSNavPanelExpandedStateForSaveMode2 -bool true

# increase window resize speed for Cocoa applications
defaults write Apple Global Domain NSWindowResizeTime -float 0.001

### activity monitor
# show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 107

### mail
# copy email addresses without names
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# add ⌘ + Enter to send email
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

### text edit
# use plain text mode for new documents
defaults write com.apple.TextEdit RichText -int 0

# open and save files as UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

### terminal
# enable Secure Keyboard Entry in terminal
# https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# disable prompt line marks
defaults write com.apple.Terminal AutoMarkPromptLines -int 0

### sublime text
SUBLIME_PREFS_DIR="$HOME/Library/Application Support/Sublime Text/Packages/User"
if [[ -d "$SUBLIME_PREFS_DIR" ]]; then
  PREFS_FILE="$SUBLIME_PREFS_DIR/Preferences.sublime-settings"
  rm -f "$PREFS_FILE" || true
  ln -sf "$HOME/.dotfiles/prefs/sublime-prefs.json" "$PREFS_FILE"
fi

# restart affected apps
for app in "Activity Monitor" "Mail" "TextEdit" "Finder" "Dock" "SystemUIServer" "Terminal"; do
  killall "${app}" &> /dev/null || true
done
