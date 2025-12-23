#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install nerdfonts.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_warn "Skipping: Not macOS"; return 0; }

fonts_list=(
    font-fira-mono-nerd-font
    font-fira-code-nerd-font
)

if ! brew list "${fonts_list[@]}" &> /dev/null; then
    brew tap homebrew/cask-fonts
    for font in "${fonts_list[@]}"; do
        brew install --cask "$font"
    done
fi

unset fonts_list
