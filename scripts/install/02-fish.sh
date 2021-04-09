#!/usr/bin/env bash
if not_installed "fish"; then
    add_ppa "fish-shell/release-3"
    update
    install fish
fi
fish --version

fisher_location="$HOME/.config/fish/functions/fisher.fish"
if ! [ -f "$fisher_location" ]; then
    curl https://git.io/fisher --create-dirs -sLo "$fisher_location"
    fish -c "fisher install jorgebucaran/fisher"
fi

fish -c "fisher --version"
