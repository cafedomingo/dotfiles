#!/bin/bash

# Script to load the lpl terminal color scheme and set it as default

echo "Importing lpl terminal color scheme..."

# Full path to the color scheme file
SCHEME_PATH="$(pwd)/prefs/lpl.terminal"

# Check if the file exists
if [ ! -f "$SCHEME_PATH" ]; then
  echo "Error: Color scheme file not found at $SCHEME_PATH"
  exit 1
fi

# Import the color scheme using osascript
osascript <<EOD
tell application "Terminal"
  set themeName to "lpl"

  # First, check if the theme already exists
  set themeExists to false
  set availableSettings to name of every settings set

  repeat with aSettingName in availableSettings
    if aSettingName is equal to themeName then
      set themeExists to true
      exit repeat
    end if
  end repeat

  # If theme doesn't exist, import it
  if not themeExists then
    do shell script "open '$SCHEME_PATH'"
    delay 1 # Give Terminal time to process
  end if

  # Set the theme as default
  set default settings to settings set themeName

  # Apply to current window
  set current settings of front window to settings set themeName

  # Confirm
  display dialog "The 'lpl' color scheme has been set as the default Terminal theme."
end tell
EOD

echo "Terminal color scheme has been imported and set as default."
