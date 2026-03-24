#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Configure defaults
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

# Only write if value differs from desired
_defaults_set() {
    local domain="$1" key="$2" type="$3" value="$4"
    local current
    current=$(defaults read "$domain" "$key" 2>/dev/null) || current=""
    [[ "$current" == "$value" ]] && return 0
    defaults write "$domain" "$key" "$type" "$value"
}

# Keyboard
_defaults_set -globalDomain NSAutomaticCapitalizationEnabled -bool false
_defaults_set -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
_defaults_set -globalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
_defaults_set NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
_defaults_set NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
_defaults_set NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

# Appearance
_defaults_set -globalDomain AppleAquaColorVariant -int 6
_defaults_set -globalDomain AppleInterfaceStyle -string Dark
_defaults_set -globalDomain AppleHighlightColor -string "0.172549 0.705882 0.580392"

# Control Center
_defaults_set ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Bluetooth -int 24
_defaults_set ~/Library/Preferences/ByHost/com.apple.controlcenter.plist WiFi -int 24
_defaults_set ~/Library/Preferences/ByHost/com.apple.controlcenter.plist NowPlaying -int 24
_defaults_set ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Battery -int 24

# Finder
_defaults_set com.apple.finder QuitMenuItem -bool true
_defaults_set com.apple.finder AppleShowAllFiles -bool true
_defaults_set NSGlobalDomain AppleShowAllExtensions -bool true
_defaults_set com.apple.finder FXEnableExtensionChangeWarning -bool false
_defaults_set com.apple.finder ShowPathbar -bool true
_defaults_set com.apple.finder ShowStatusBar -bool true
_defaults_set com.apple.finder _FXSortFoldersFirst -bool true
_defaults_set com.apple.CrashReporter DialogType -string none
_defaults_set com.apple.dashboard mcx-disabled -bool true
_defaults_set com.apple.finder ShowHardDrivesOnDesktop -bool true
_defaults_set com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
_defaults_set com.apple.finder ShowRemovableMediaOnDesktop -bool true
_defaults_set com.apple.finder ShowMountedServersOnDesktop -bool true
_defaults_set com.apple.finder ShowRecentTags -bool false
_defaults_set com.apple.desktopservices DSDontWriteUSBStores -bool true
_defaults_set com.apple.desktopservices DSDontWriteNetworkStores -bool true
_defaults_set com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
_defaults_set com.apple.finder FXPreferredViewStyle -string nlsv

# Spotlight
_defaults_set com.apple.Spotlight MenuItemHidden -int 1

# Dock
_defaults_set com.apple.dock show-recents -bool false
_defaults_set com.apple.dock scroll-to-open -bool true

# Remove default apps from the dock
dock_state=$(defaults read com.apple.dock persistent-apps 2>/dev/null || echo "")
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
for default_app in "${default_apps[@]}"; do
    [[ $dock_state == *"$default_app"* ]] && dockutil --remove "$default_app" --no-restart 1>/dev/null 2>&1 || true
done

# Set up apps in the dock
dock_order=(
    "/System/Library/CoreServices/Finder.app" # Cannot be moved
    "/System/Applications/App Store.app"
    "/System/Applications/Apps.app"
    "/System/Applications/System Settings.app"
    "/System/Applications/Utilities/Activity Monitor.app"
    "/Applications/iTerm.app"
)
for i in "${!dock_order[@]}"; do
    if [[ $i -ne 0 ]]; then
        path="${dock_order[$i]}"
        name=$(basename "$path" | sed 's/\.app$//')
        if [[ $dock_state == *"$name"* ]]; then
            dockutil --move "${path}" --position "$i" --no-restart 2>/dev/null || true
        else
            dockutil --add "${path}" --position "$i" --no-restart 2>/dev/null || true
        fi
    fi
done
if [[ ! $dock_state == *"spacer"* ]]; then
    dockutil --add '' --type spacer --section apps --position "${#dock_order[@]}" --no-restart 2>/dev/null || true
fi

log_info "Restart Finder/Dock to apply: osascript -e 'quit app \"Finder\"'"
log_pass "macOS defaults configured"
