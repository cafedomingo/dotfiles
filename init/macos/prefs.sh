#!/usr/bin/env bash

# inspired by: https://mths.be/macos

# `defaults find` is good at finding some set preferences.
# e.g.    defaults find com.apple.ActivityMonitor

# close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# ask for the administrator password upfront
sudo -v

# keep-alive: update existing `sudo` time stamp until `macos.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

################################################################################
# localization
################################################################################
# set language
defaults write NSGlobalDomain AppleLanguages -array "en-US"
defaults write NSGlobalDomain AppleLocale -string "en_US"

################################################################################
# finder
################################################################################
# set Home as the default location for new Finder windows
## for other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string 'PfHm'
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# show finder status bar
defaults write com.apple.finder ShowStatusBar -bool true

# show finder path bar
defaults write com.apple.finder ShowPathbar -bool true

# search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# set the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0.5

# avoid creating .DS_Store files on network or usb volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# automatically open a new finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# enable snap-to-grid for icons on the desktop and other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# increase grid spacing for icons on the desktop and other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

# set the size of icons on the desktop and other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist

# use list view in all finder windows by default
## codes for the view modes: `Nlsv`, `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# show the ~/Library folder
chflags nohidden ~/Library

# show the /Volumes folder
sudo chflags nohidden /Volumes

# expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  MetaData -bool true \
  OpenWith -bool true \
  Privileges -bool true

killall "Finder" &> /dev/null

################################################################################
# desktop & dock
################################################################################
# position the dock on the left
defaults write com.apple.dock orientation -string "left"

# set the icon size of Dock items to 32 pixels
defaults write com.apple.dock tilesize -int 32

# set minimize/maximize window effect
defaults write com.apple.dock mineffect -string "genie"

# minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# enable spring loading for all dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# enable app exposé gesture (swipe down with 3 fingers)
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# disable the Launchpad gesture (pinch with thumb and three fingers)
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# disable Dashboard
defaults write com.apple.dashboard dashboard-enabled-state -int 1

# remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# speed up animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float .2

# automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# hot corners
# possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# bottom left screen corner → start screen saver
#defaults write com.apple.dock wvous-bl-corner -int 5
#defaults write com.apple.dock wvous-bl-modifier -int 0

killall "Dock" &> /dev/null

################################################################################
# desktop & dock
################################################################################
# trackpad: two finger tap to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# use dark theme
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# show battery life percentage.
defaults write com.apple.menuextra.battery ShowPercent -bool true

# enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# use f keys as standard function keys
defaults write NSGlobalDomain com.apple.keyboard.fnState -int 1

# disable press-and-hold for keys in favor of key repeat
#defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# set keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2          # normal minimum is 2 (30 ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 25  # normal minimum is 15 (225 ms)

# disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

################################################################################
# screen
################################################################################
# require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

################################################################################
# timemachine
################################################################################
# prevent prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

################################################################################
# ux
################################################################################
# disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# set sidebar icon size to small
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

killall SystemUIServer &> /dev/null

################################################################################
# app store
################################################################################
# enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

# allow the app store to reboot machine on macOS updates
defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

killall "App Store" &> /dev/null

################################################################################
# chrome
################################################################################
if [[ -d /Applications/Google\ Chrome.app ]]; then
  # disable the all too sensitive backswipe on trackpads
  defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

  # disable the all too sensitive backswipe on Magic Mouse
  defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false

  # use the system-native print preview dialog
  defaults write com.google.Chrome DisablePrintPreview -bool true

  # expand the print dialog by default
  defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true

  killall "Google Chrome" &> /dev/null
fi

################################################################################
# photos
################################################################################
# disable opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

killall "Photos" &> /dev/null

################################################################################
# safari
################################################################################
# privacy
# don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
# enable do not track header
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
# block third party cookies
defaults write com.apple.Safari BlockStoragePolicy -int 2
# websites request location once per day
defaults write com.apple.Safari SafariGeolocationPermissionPolicy -int 1
# use duckduckgo
/usr/libexec/PlistBuddy -c "Set :NSPreferredWebServices:NSWebServicesProviderWebSearch:NSDefaultDisplayName DuckDuckGo" ~/Library/Preferences/.GlobalPreferences.plist
/usr/libexec/PlistBuddy -c "Set :NSPreferredWebServices:NSWebServicesProviderWebSearch:NSProviderIdentifier com.duckduckgo" ~/Library/Preferences/.GlobalPreferences.plist

# security
# don't open ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
# warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true
# disable plug-ins
defaults write com.apple.Safari WebKitPluginsEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false
# disable java
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
# if plugins are ever enabled, stop them to save power
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PlugInSnapshottingEnabled -bool true
# update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

# default to utf-8 encoding
defaults write com.apple.Safari.WebKitDefaultTextEncodingName -string "utf-8"
defaults write com.apple.Safari.com.apple.Safari.ContentPageGroupIdentifier.WebKit2DefaultTextEncodingName -string "utf-8"

# tab highlights each item on a web page
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

# show the full URL in the address bar
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# open new windows and tabs with empty page
defaults write com.apple.Safari NewWindowBehavior -int 1
defaults write com.apple.Safari NewTabBehavior -int 1

# hide favorites bar
defaults write com.apple.Safari ShowFavoritesBar-v2 -bool false

# show sidebar in top sites
defaults write com.apple.Safari ShowSidebarInTopSites -bool true

# enable developer tools (develop/debug menus, webkit inspector)
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
# add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# mmake safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# enable continuous spellchecking
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
# disable auto-correct
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# disable autofill
defaults write com.apple.Safari AutoFillFromAddressBook -bool true
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

# enable apple pay
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2ApplePayCapabilityDisclosureAllowed -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2ApplePayEnabled -bool true

# block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

killall "Safari" &> /dev/null

################################################################################
# sublime text 3
################################################################################
# link preferences - NOTE: assumes dotfiles are located at ~/.dotfiles
if [[ -d ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User ]]; then
  if [[ -f ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings ]]; then
    rm -f ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings
  fi;

  ln -s ~/.dotfiles/prefs/sublime-prefs.json ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings &> /dev/null
fi;

################################################################################
# system apps
################################################################################
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

################################################################################
# terminal & iterm
################################################################################
# only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# enable Secure Keyboard Entry in terminal
## https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# disable the annoying line marks
defaults write com.apple.Terminal ShowLineMarks -int 0

if [[ -d /Applications/iTerm.app ]]; then
  # don’t display the annoying prompt when quitting iTerm
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false
fi

################################################################################
# transmission
################################################################################
if [[ -d /Applications/Transmission.app ]]; then
  # use `~/Downloads` to store incomplete downloads
  defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
  defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads"

  # don’t prompt for confirmation before downloading
  defaults write org.m0k.transmission DownloadAsk -bool false
  defaults write org.m0k.transmission MagnetOpenAsk -bool false

  # trash original torrent files
  defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

  # hide the donate message
  defaults write org.m0k.transmission WarningDonate -bool false
  # hide the legal disclaimer
  defaults write org.m0k.transmission WarningLegal -bool false

  # always use encryption
  defaults write org.m0k.transmission EncryptionPrefer -bool true
  defaults write org.m0k.transmission EncryptionRequire -bool true

  # stop at seed ratio of 2
  defaults write org.m0k.transmission RatioCheck -bool true
  defaults write org.m0k.transmission RatioLimit -int 2

  # ip block list
  ## https://giuliomac.wordpress.com/2014/02/19/best-blocklist-for-transmission/
  defaults write org.m0k.transmission BlocklistNew -bool true
  defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"
  defaults write org.m0k.transmission BlocklistAutoUpdate -bool true

  killall "Transmission" &> /dev/null
fi
