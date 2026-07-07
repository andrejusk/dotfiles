#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Rectangle.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^rectangle$"; then
    brew install --cask rectangle
fi
log_pass "Rectangle installed"
echo "$BREW_CASK_VERSIONS" | grep "^rectangle " | log_quote || true

# Configure Rectangle defaults. Reload once at the end if anything changed so
# the new values apply without a manual restart.
_rect_changed=0
_rect_set() {  # key type value human-label
    if [[ "$(defaults read com.knollsoft.Rectangle "$1" 2>/dev/null)" != "$3" ]]; then
        defaults write com.knollsoft.Rectangle "$1" "$2" "$3"
        _rect_changed=1
        log_pass "Rectangle $4"
    else
        log_skip "Rectangle $4 already set"
    fi
}

# Gap/padding between snapped windows (and screen edges).
_rect_set gapSize -float 8 "gap = 8px"

# Repeated-command behaviour: acrossAndResize (3) — repeating a left/right
# command moves the window to the adjacent display, while other repeats cycle
# the window size (halves/thirds). Default is resize (0). See Rectangle's
# SubsequentExecutionMode enum.
_rect_set subsequentExecutionMode -int 3 "repeated commands = across-monitor + resize"

if [[ "$_rect_changed" == 1 ]] && pgrep -x Rectangle >/dev/null; then
    osascript -e 'quit app "Rectangle"' 2>/dev/null || true
    sleep 1
    open -a Rectangle 2>/dev/null || true
fi
