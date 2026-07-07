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

# Like _defaults_set, but for the per-host NSGlobalDomain (ByHost) mirror. The
# trackpad/gesture engine reads these com.apple.trackpad.* keys (not just the
# app domains), so gesture settings must be written here too.
_defaults_set_ch() {
    local key="$1" type="$2" value="$3"
    local current
    current=$(defaults -currentHost read -g "$key" 2>/dev/null) || current=""
    [[ "$current" == "$value" ]] && return 0
    defaults -currentHost write -g "$key" "$type" "$value"
}

# Keyboard
_defaults_set -globalDomain NSAutomaticCapitalizationEnabled -bool false
_defaults_set -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
_defaults_set -globalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
_defaults_set NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
_defaults_set NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
_defaults_set NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

# Dictation (on-device; hold Globe 🌐 key to dictate)
_defaults_set com.apple.assistant.support "Dictation Enabled" -bool true
_defaults_set com.apple.HIToolbox AppleDictationAutoEnable -int 1
_defaults_set com.apple.HIToolbox AppleFnUsageType -int 3

# Appearance (light/dark is intentionally NOT forced here — it's controlled
# per-machine via System Settings, and DOTS_THEME detection follows it. See
# home/.profile's _dots_detect_theme.)
_defaults_set -globalDomain AppleAquaColorVariant -int 6
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

# Spotlight: exclude the code workspace from indexing. mds/mds_stores otherwise
# continuously reindexes large repos + build output — a top CPU/disk load source
# that also adds latency to file ops. `.metadata_never_index` is the documented
# per-folder opt-out (no sudo, survives reindex); it takes effect on the next
# index pass. Extend the list with any other heavy trees (caches, toolchains).
for _spotlight_exclude in "$HOME/Workspace"; do
    mkdir -p "$_spotlight_exclude"
    touch "$_spotlight_exclude/.metadata_never_index"
done
unset _spotlight_exclude

# Dock
_defaults_set com.apple.dock show-recents -bool false
_defaults_set com.apple.dock scroll-to-open -bool true
_defaults_set com.apple.dock tilesize -int 62
# Bottom-left hot corner -> Start Screen Saver (5), no modifier key (0).
_defaults_set com.apple.dock wvous-bl-corner -int 5
_defaults_set com.apple.dock wvous-bl-modifier -int 0

# Window management: disable drag-to-edge tiling (conflicts with Rectangle).
# Backs System Settings > Desktop & Dock > Windows >
# "Drag windows to screen edges to tile".
_defaults_set com.apple.WindowManager EnableTilingByEdgeDrag -bool false
_defaults_set com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false

# Trackpad: three-finger drag (move windows, select text, etc.) on the built-in
# and Bluetooth trackpads. Three-finger drag can't coexist with three-finger
# swipes, so disable those — macOS keeps "swipe between full-screen apps" and
# Mission Control on FOUR fingers (TrackpadFourFinger*SwipeGesture, left at 2).
# The gesture engine reads the per-host mirror, so set both stores.
_defaults_set com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
_defaults_set com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
_defaults_set com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0
_defaults_set com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
_defaults_set com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
_defaults_set com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 0
_defaults_set_ch com.apple.trackpad.threeFingerDragGesture -int 1
_defaults_set_ch com.apple.trackpad.threeFingerHorizSwipeGesture -int 0
_defaults_set_ch com.apple.trackpad.threeFingerVertSwipeGesture -int 0

# Scrolling: traditional direction (i.e. "natural scrolling" off).
_defaults_set NSGlobalDomain com.apple.swipescrolldirection -bool false

# Tiling + trackpad changes require a logout (or WindowServer restart) to apply.
log_info "Restart Finder/Dock to apply: osascript -e 'quit app \"Finder\"'"
log_info "Log out/in to apply tiling + trackpad changes"
log_pass "macOS defaults configured"
