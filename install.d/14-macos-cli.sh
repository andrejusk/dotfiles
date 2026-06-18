#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install CLI utilities that have no suitable mise backend:
#     - coreutils: GNU userland (gls) so the custom LS_COLORS palette applies
#                  to `ls` (BSD ls ignores LS_COLORS — see ~/.zshrc).
#     - dockutil:  script the macOS Dock layout (complements 90-macos.sh).
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

formulae=(coreutils dockutil)
for formula in "${formulae[@]}"; do
    if ! echo "$BREW_FORMULAE" | grep -q "^${formula}$"; then
        brew install "$formula"
    fi
done
unset formula formulae

log_pass "macOS CLI utilities installed"
echo "$BREW_FORMULA_VERSIONS" | grep -E "^(coreutils|dockutil) " | log_quote || true
