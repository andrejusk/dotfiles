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

    # off -- Keyboard: Auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

    # Appearance
    # ----------
    # Graphite -- Appearance (prevent top-left window colours)
    defaults write -globalDomain AppleAquaColorVariant -int 6

    # on -- Appearance: Dark mode
    defaults write -globalDomain AppleInterfaceStyle -string "Dark"

    # #2CB494 -- Highlight color
    defaults write -globalDomain AppleHighlightColor -string "0.172549 0.705882 0.580392"

    killall SystemUIServer 2>/dev/null || true

    # Control Center
    # --------------
    # off -- Control Center: Show Bluetooth icon in menu bar
    defaults write \
        ~/Library/Preferences/ByHost/com.apple.controlcenter.plist \
        Bluetooth \
        -int 24

    # off -- Control Center: Show Wi-Fi icon in menu bar
    defaults write \
        ~/Library/Preferences/ByHost/com.apple.controlcenter.plist \
        WiFi \
        -int 24

    # off -- Control Center: Show Now Playing icon in menu bar
    defaults write \
        ~/Library/Preferences/ByHost/com.apple.controlcenter.plist \
        NowPlaying \
        -int 24

    # off -- Control Center: Show Battery icon in menu bar
    defaults write \
        ~/Library/Preferences/ByHost/com.apple.controlcenter.plist \
        Battery \
        -int 24

    killall ControlCenter 2>/dev/null || true

    # Finder
    # ------
    # on -- Finder: Add quit option
    defaults write com.apple.finder QuitMenuItem -bool true

    # on -- Finder: Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # on -- Finder: Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # off -- Finder: Show warning before changing an extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # on -- Finder: Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # on -- Finder: Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # on -- Finder: Keep folders on top
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # off -- Finder: Use macOS Crash Reporter
    defaults write com.apple.CrashReporter DialogType -string "none"

    # off -- Finder: Enable dashboard widgets
    defaults write com.apple.dashboard mcx-disabled -bool true

    # on -- Finder: Show hard drives on desktop
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

    # on -- Finder: Show external hard drives on desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

    # on -- Finder: Show removable media on desktop
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # on -- Finder: Show mounted servers on desktop
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

    # off -- Finder: Show recent tags
    defaults write com.apple.finder ShowRecentTags -bool false

    # off -- Finder: Create .DS_Store files
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

    # home -- Finder: New Finder windows show
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

    # list -- Finder: Preferred view style
    defaults write com.apple.finder FXPreferredViewStyle -string "nlsv"

    killall Finder 2>/dev/null || true

    # Spotlight
    # ---------
    # on -- Spotlight: Hide menu bar icon
    defaults write com.apple.Spotlight MenuItemHidden -int 1

    killall Spotlight 2>/dev/null || true

    # Dock
    # ----
    # off -- Dock: Show recent applications
    defaults write com.apple.dock show-recents -bool false

    # on -- Dock: Use scroll gestures
    defaults write com.apple.dock scroll-to-open -bool true

    # Remove default apps from the dock
    default_apps=(
        "Messages"
        "Mail"
        "Maps"
        "Photos"
        "FaceTime"
        "Calendar"
        "Contacts"
        "Reminders"
        "Freeform"
        "TV"
        "Music"
        "News"
        "Keynote"
        "Numbers"
        "Pages"
    )
    for default_app in default_apps; do
        dockutil --remove "$default_app" --no-restart 1>/dev/null 2>&1 || true
    done

    # Set up apps in the dock
    dock_order=(
        "/System/Library/CoreServices/Finder.app" # Cannot be moved
        "/System/Applications/App Store.app"
        "/System/Applications/Launchpad.app"
        "/System/Applications/System Settings.app"
        "/System/Applications/Utilities/Activity Monitor.app"
        "/Applications/iTerm.app"
    )
    dock_state=$(defaults read com.apple.dock persistent-apps)
    for i in "${!dock_order[@]}"; do
        if [[ $i -ne 0 ]]; then
            path="${dock_order[$i]}"
            name=$(basename "$path" | sed 's/\.app$//')
            if [[ $dock_state == *"$name"* ]]; then
                dockutil --move "${path}" --position $i --no-restart
            else
                dockutil --add "${path}" --position $i --no-restart
            fi
        fi
    done
    if [[ ! $dock_state == *"spacer"* ]]; then
        dockutil --add '' --type spacer --section apps --position "${#dock_order[@]}" --no-restart
    fi

    killall Dock 2>/dev/null || true
else
    echo "Skipping: Not macOS"
fi
