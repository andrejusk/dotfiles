#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install nerdfonts.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

fonts_list=(
    font-fira-mono-nerd-font
    font-fira-code-nerd-font
)

# Check if any fonts are missing
fonts_missing=false
for font in "${fonts_list[@]}"; do
    if ! echo "$BREW_CASKS" | grep -q "^$font$"; then
        fonts_missing=true
        break
    fi
done

if [[ "$fonts_missing" == "true" ]]; then
    brew tap homebrew/cask-fonts
    for font in "${fonts_list[@]}"; do
        if ! echo "$BREW_CASKS" | grep -q "^$font$"; then
            brew install --cask "$font"
        fi
    done
fi

unset fonts_list fonts_missing
log_pass "Nerd Fonts installed"
