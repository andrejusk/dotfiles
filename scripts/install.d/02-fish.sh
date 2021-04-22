#!/usr/bin/env bash
fish --version

current_shell=`readlink -f /proc/$$/exe`
fish_shell=`which fish`
if [[ "$current_shell" != "$fish_shell" ]]; then
    chsh -s "$fish_shell"
fi

fisher_location="$XDG_CONFIG_HOME/fish/functions/fisher.fish"
if ! [ -f $fisher_location ]; then
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fi

fish -c "fisher update"
fish -c "fisher --version"
