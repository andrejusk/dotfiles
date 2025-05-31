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

    if ! brew list "${fonts_list[@]}" &> /dev/null; then
        brew tap homebrew/cask-fonts
        for font in "${fonts_list[@]}"; do
            brew install --cask "$font"
        done
    fi

    unset fonts_list
else
    echo -e "${YELLOW}Skipping: Not macOS${NC}"
fi
