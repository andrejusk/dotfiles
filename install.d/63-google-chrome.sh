#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Google Chrome (Homebrew Cask managed).
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if echo "$BREW_CASKS" | grep -q "^google-chrome$"; then
    log_skip "Chrome already cask-managed"
else
    # --adopt takes ownership of an existing /Applications/Google Chrome.app
    # (e.g. a one-off manual install) instead of erroring on the collision, so
    # brew manages upgrades from here on. Requires Homebrew >= 4.3.0.
    brew install --cask --adopt google-chrome
fi
log_pass "Chrome installed"
echo "$BREW_CASK_VERSIONS" | grep "^google-chrome " | log_quote || true

# Updates are owned by Homebrew, not Google's background updater. Chrome installs
# "Keystone" (com.google.Keystone.Agent), which registers launchd wake jobs and
# polls for updates every checkInterval seconds (default 18000 = 5h). Setting it
# to 0 disables the periodic BACKGROUND check — declarative on every machine
# rather than a per-machine GUI tweak. On-demand updates still work (Chrome menu >
# About Google Chrome), and since the cask is `auto_updates true` brew otherwise
# defers to Chrome's self-updater, so pull updates explicitly with:
#     brew upgrade --cask --greedy google-chrome
# Only write if the value differs, matching _defaults_set in 90-macos.sh (which
# isn't in scope here — it's defined later, in a script sourced after this one).
if [[ "$(defaults read com.google.Keystone.Agent checkInterval 2>/dev/null)" != "0" ]]; then
    defaults write com.google.Keystone.Agent checkInterval -int 0
    log_pass "Chrome background auto-update disabled (checkInterval 0; update via brew --greedy)"
else
    log_skip "Chrome background auto-update already disabled"
fi
