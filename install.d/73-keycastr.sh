#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install KeyCastr.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^keycastr$"; then
    # --adopt takes over an existing manual /Applications/KeyCastr.app instead of erroring.
    brew install --cask --adopt keycastr
fi
log_pass "KeyCastr installed"
echo "$BREW_CASK_VERSIONS" | grep "^keycastr " | log_quote || true
