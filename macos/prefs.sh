#!/usr/bin/env bash

set -euo pipefail

# validate we're running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "❌ This script is only for macOS"
  exit 1
fi

# parse command line arguments
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-n|--dry-run] [-h|--help]"
      echo "  -n, --dry-run  Show what would be changed without making changes"
      echo "  -h, --help     Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h or --help for usage information"
      exit 1
      ;;
  esac
done

# constants and configuration
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# applications that need to be restarted after preference changes
readonly RESTART_APPS=("Activity Monitor" "Dock" "Finder" "SystemUIServer" "TextEdit")

# normalize boolean values for comparison (1/0 vs true/false)
normalize_bool() {
  local value="$1"
  case "$value" in
    "1") echo "true" ;;
    "0") echo "false" ;;
    *) echo "$value" ;;
  esac
}

# set a defaults preference with dry-run support
setting() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  local current_value
  current_value=$(defaults read "$domain" "$key" 2>/dev/null || echo "NOT SET")

  # normalize for comparison if boolean
  local normalized_current="$current_value"
  local normalized_new="$value"
  if [[ "$type" == "bool" ]]; then
    normalized_current=$(normalize_bool "$current_value")
    normalized_new=$(normalize_bool "$value")
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    if [[ "$normalized_current" == "$normalized_new" ]]; then
      echo -e "${GREEN}✓${NC} $domain.$key = ${YELLOW}$current_value${NC} (no change)"
    else
      echo -e "${RED}→${NC} $domain.$key: ${YELLOW}$current_value${NC} → ${GREEN}$value${NC} ($type)"
    fi
  else
    if [[ "$normalized_current" != "$normalized_new" ]]; then
      echo "Setting $domain $key to $value"
      defaults write "$domain" "$key" "-$type" "$value"
    else
      echo "✓ $domain $key already set to $value"
    fi
  fi
}

# set a dictionary value with dry-run support
dict_setting() {
  local domain="$1"
  local key="$2"
  local dict_key="$3"
  local dict_value="$4"

  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${BLUE}→${NC} $domain.$key -dict-add $dict_key $dict_value"
  else
    echo "Setting $domain $key -dict-add $dict_key $dict_value"
    defaults write "$domain" "$key" -dict-add "$dict_key" "$dict_value"
  fi
}

# execute a command with dry-run support
cmd() {
  local description="$1"
  local command="$2"

  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${BLUE}→${NC} $description"
  else
    echo "$description"
    eval "$command"
  fi
}

# set multiple dictionary values at once
dict_batch() {
  local domain="$1"
  local key="$2"
  local description="$3"
  shift 3

  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${BLUE}→${NC} $description"
  else
    echo "$description"
    defaults write "$domain" "$key" -dict "$@"
  fi
}

# show/hide file or folder
toggle_visibility() {
  local path="$1"
  local name="$2"

  if [[ "$DRY_RUN" == "true" ]]; then
    if [[ $(ls -dlO "$path" 2>/dev/null | awk '{print $5}') == *"hidden"* ]]; then
      echo -e "${RED}→${NC} $name: ${YELLOW}hidden${NC} → ${GREEN}visible${NC}"
    else
      echo -e "${GREEN}✓${NC} $name already visible"
    fi
  else
    echo "Making $name folder visible"
    chflags nohidden "$path"
  fi
}

# create symlink for application preferences
symlink_prefs() {
  local app_name="$1"
  local source_file="$2"
  local target_file="$3"

  # check if symlink already exists and is correct
  if [[ -L "$target_file" ]] && [[ "$(readlink "$target_file")" == "$source_file" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      echo -e "${GREEN}✓${NC} $app_name prefs already symlinked correctly"
    else
      echo "✓ $app_name prefs already symlinked correctly"
    fi
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      echo -e "${BLUE}→${NC} Symlink $app_name prefs: $source_file → $target_file"
    else
      mkdir -p "$(dirname "$target_file")"
      rm -f "$target_file" || true
      ln -sf "$source_file" "$target_file"
      echo "✓ $app_name prefs symlinked"
    fi
  fi
}

# check for trackpad (built-in or external)
has_trackpad() {
  command ioreg | command grep -q "AppleMultitouchTrackpad" || \
  command system_profiler SPBluetoothDataType | command grep -iq "trackpad\|magic trackpad" || \
  command system_profiler SPUSBDataType | command grep -iq "magic trackpad"
}

# determine script location for relative paths
SCRIPT_DIR="$(dirname "$0")"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${YELLOW}=== DRY RUN MODE - NO CHANGES WILL BE MADE ===${NC}"
fi

# close System Settings
cmd "Close System Settings" 'osascript -e '\''tell application "System Settings" to quit'\'''

### finder
echo -e "${GREEN}=== Configuring Finder ===${NC}"

# show status bar
setting "com.apple.finder" "ShowStatusBar" "bool" "true"

# show path bar
setting "com.apple.finder" "ShowPathbar" "bool" "true"

# set sidebar icon size to small
setting "Apple Global Domain" "NSTableViewDefaultSizeMode" "int" "1"

# search the current folder by default
setting "com.apple.finder" "FXDefaultSearchScope" "string" "SCcf"

# set home as the default location for new windows
setting "com.apple.finder" "NewWindowTarget" "string" "PfHm"

# enable snap-to-grid for icons on the desktop and other icon views
dict_setting "com.apple.finder" "DesktopViewSettings" "IconViewSettings" "-dict arrangeBy grid"
dict_setting "com.apple.finder" "FK_StandardViewSettings" "IconViewSettings" "-dict arrangeBy grid"
dict_setting "com.apple.finder" "StandardViewSettings" "IconViewSettings" "-dict arrangeBy grid"

# use list view in all finder windows by default
setting "com.apple.finder" "FXPreferredViewStyle" "string" "Nlsv"

# show the ~/Library folder
toggle_visibility "$HOME/Library" "~/Library"

# expand file info panes
dict_batch "com.apple.finder" "FXInfoPanesExpanded" "Expand Finder info panes" \
  General -bool true \
  MetaData -bool true \
  OpenWith -bool true \
  Privileges -bool true

### desktop / dock
echo -e "${GREEN}=== Configuring Desktop & Dock ===${NC}"

# dark mode
setting "Apple Global Domain" "AppleInterfaceStyle" "string" "Dark"

# position the dock on the left
setting "com.apple.dock" "orientation" "string" "left"

# set the icon size of Dock items to 32 pixels
setting "com.apple.dock" "tilesize" "int" "32"

# minimize windows into their application's icon
setting "com.apple.dock" "minimize-to-application" "bool" "true"

# enable app exposé gesture (swipe down with 3 fingers)
setting "com.apple.dock" "showAppExposeGestureEnabled" "bool" "true"

# remove the auto-hiding Dock delay
setting "com.apple.dock" "autohide-delay" "float" "0"

# speed up animation when hiding/showing the Dock
setting "com.apple.dock" "autohide-time-modifier" "float" "0.5"

# automatically hide and show the Dock
setting "com.apple.dock" "autohide" "bool" "true"

### input
echo -e "${GREEN}=== Configuring Input ===${NC}"

# trackpad settings (if available)
if has_trackpad; then
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${BLUE}→${NC} Trackpad detected: enable right-click & secondary click"
  else
    echo "Trackpad detected, configuring trackpad settings"
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
  fi
else
  echo "No trackpad detected, skipping trackpad settings"
fi

# use keyboard navigation to move focus between controls
setting "Apple Global Domain" "AppleKeyboardUIMode" "int" "2"

# set keyboard repeat rate
setting "Apple Global Domain" "KeyRepeat" "int" "2"
setting "Apple Global Domain" "InitialKeyRepeat" "int" "25"

# disable auto-capitalization
setting "Apple Global Domain" "NSAutomaticCapitalizationEnabled" "bool" "false"

# disable auto-correct
setting "Apple Global Domain" "NSAutomaticSpellingCorrectionEnabled" "bool" "false"

### misc
echo -e "${GREEN}=== Configuring Misc Settings ===${NC}"

# disable shadow in screenshots
setting "com.apple.screencapture" "disable-shadow" "bool" "true"

# expand save panel by default
setting "Apple Global Domain" "NSNavPanelExpandedStateForSaveMode" "bool" "true"
setting "Apple Global Domain" "NSNavPanelExpandedStateForSaveMode2" "bool" "true"

# increase window resize speed for Cocoa applications
setting "Apple Global Domain" "NSWindowResizeTime" "float" "0.001"

### activity monitor
echo -e "${GREEN}=== Configuring Activity Monitor ===${NC}"

# show the main window when launching Activity Monitor
setting "com.apple.ActivityMonitor" "OpenMainWindow" "bool" "true"

# visualize CPU usage in the Activity Monitor Dock icon
setting "com.apple.ActivityMonitor" "IconType" "int" "5"

# show all processes in Activity Monitor
setting "com.apple.ActivityMonitor" "ShowCategory" "int" "107"

### text edit
echo -e "${GREEN}=== Configuring TextEdit ===${NC}"

# use plain text mode for new documents
setting "com.apple.TextEdit" "RichText" "int" "0"

# open and save files as UTF-8
setting "com.apple.TextEdit" "PlainTextEncoding" "int" "4"
setting "com.apple.TextEdit" "PlainTextEncodingForWrite" "int" "4"

### sublime text
echo -e "${GREEN}=== Configuring Sublime Text ===${NC}"

symlink_prefs "Sublime Text" \
  "$DOTFILES_ROOT/prefs/sublime-prefs.json" \
  "$HOME/Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings"

### iterm2
echo -e "${GREEN}=== Configuring iTerm2 ===${NC}"

# Configure iTerm2 to load preferences from our dotfiles directory
setting "com.googlecode.iterm2" "PrefsCustomFolder" "string" "$DOTFILES_ROOT/prefs"
setting "com.googlecode.iterm2" "LoadPrefsFromCustomFolder" "bool" "true"

# restart affected apps
echo -e "${GREEN}=== Applying changes ===${NC}"

if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${BLUE}→${NC} Refresh preferences daemon (killall cfprefsd)"
  printf -v apps_list '%s, ' "${RESTART_APPS[@]}"
  echo -e "${RED}→${NC} Apps to restart: ${YELLOW}${apps_list%, }${NC}"
else
  # force preferences daemon to refresh cached preferences
  echo "Refreshing preferences daemon..."
  killall cfprefsd 2>/dev/null || true

  for app in "${RESTART_APPS[@]}"; do
    echo "Restarting $app..."
    killall "${app}" &> /dev/null || true
  done
  echo -e "${GREEN}✓ Configuration complete!${NC}"
fi
