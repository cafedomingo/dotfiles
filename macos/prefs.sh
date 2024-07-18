#!/usr/bin/env bash

# inspired by: https://mths.be/macos
# `defaults find` is good at finding some set preferences.

# close System Preferences, to prevent overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

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
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# set home as the default location for new windows
defaults write com.apple.finder NewWindowTarget -string 'PfHm'

# show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# automatically open a new finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# enable snap-to-grid for icons on the desktop and other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# use list view in all finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# show the ~/Library & /Volumes folders
chflags nohidden ~/Library
sudo chflags nohidden /Volumes

# expand the following file info panes:
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  MetaData -bool true \
  OpenWith -bool true \
  Privileges -bool true

killall "Finder" &> /dev/null


### desktop / dock
# dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# position the dock on the left
defaults write com.apple.dock orientation -string "left"

# set the icon size of Dock items to 32 pixels
defaults write com.apple.dock tilesize -int 32

# minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# enable app exposé gesture (swipe down with 3 fingers)
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# speed up animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float .5

# automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

killall "Dock" &> /dev/null


### input
# trackpad two finger tap to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# use keyboard navigation to move focus between controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2

# set keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2          # normal minimum is 2 (30 ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 25  # normal minimum is 15 (225 ms)

# disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false


### misc
# avoid creating .DS_Store files on network or usb volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# disable font smoothing
defaults -currentHost write -g AppleFontSmoothing -int 0

killall SystemUIServer &> /dev/null


### activity monitor
# show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 100


### mail
# copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>`
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"


### text edit
# use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# open and save files as UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

for app in "Activity Monitor" "Mail" "Text Edit"; do
  killall "${app}" &> /dev/null
done


### terminal
# enable Secure Keyboard Entry in terminal
# https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# disable the prompt line marks
defaults write com.apple.Terminal AutoMarkPromptLines -int 0


### sublime text
# link preferences
if [[ -d "$HOME/Library/Application Support/Sublime Text/Packages/User" ]]; then
  rm "$HOME/Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings"
  ln -s "$HOME/.dotfiles/prefs/sublime-prefs.json" "$HOME/Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings" &> /dev/null
fi;
