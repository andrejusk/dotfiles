#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Configure defaults
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Keyboard
    # --------
    # off -- Keyboard: Capitalize words automatically
    defaults write -globalDomain NSAutomaticCapitalizationEnabled -bool false

    # off -- Keyboard: Add period with double-space
    defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    # off -- Keyboard: Quote substitution
    defaults write -globalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # off -- Keyboard: Dash substitution
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Appearance
    # ----------
    # Multicolour -- Appearance
    defaults write -globalDomain AppleAquaColorVariant -int 0

    # on -- Appearance: Dark mode
    defaults write -globalDomain AppleInterfaceStyle -string "Dark"

    # #2CB494 -- Highlight color
    defaults write -globalDomain AppleHighlightColor -string "0.172549 0.705882 0.580392"

    # Control Center
    # --------------
    # off -- Control Center: Show Bluetooth
    defaults write \
        ~/Library/Preferences/ByHost/com.apple.controlcenter.plist \
        Bluetooth \
        -int 24

    # off -- Control Center: Show Wi-Fi
    defaults write \
        ~/Library/Preferences/ByHost/com.apple.controlcenter.plist \
        WiFi \
        -int 24

    # Finder
    # ------
    # on -- Finder: Add quit option
    defaults write com.apple.finder QuitMenuItem -bool false
fi
