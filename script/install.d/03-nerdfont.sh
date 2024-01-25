#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install nerdfonts.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    fonts_list=(
        font-fira-mono-nerd-font
        font-fira-code-nerd-font
    )

    brew tap homebrew/cask-fonts
    for font in "${fonts_list[@]}"; do
        brew install --cask "$font"
    done

    unset fonts_list
fi
