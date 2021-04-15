#!/usr/bin/env bash
fish --version

fisher_location="$XDG_CONFIG_HOME/fish/functions/fisher.fish"
if ! [ -f $fisher_location ]; then
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fi

fish -c "fisher update"
fish -c "fisher --version"
