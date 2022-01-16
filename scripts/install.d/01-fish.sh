#!/usr/bin/env bash

#
# Run post-installation fish setup
#


fish --version

# Ensure fish is set as user shell
current_shell=$(grep "^$USER" /etc/passwd)
current_shell=${current_shell##*:}
fish_shell=$(command -v fish)
if [[ "$current_shell" != "$fish_shell" ]]; then
    echo "Changing default user shell to $fish_shell..."
    sudo usermod --shell "$fish_shell" "$USER"
else
    echo "Fish is already default user shell"
fi

# Ensure fisher is installed
fisher_location="$XDG_CONFIG_HOME/fish/functions/fisher.fish"
if ! [ -f $fisher_location ]; then
    echo "Installing fisher..."
    fish -c "curl -sL https://git.io/fisher | source && fisher update"
else
    echo "Fisher is already present"
fi

# Ensure fisher is up-to-date
fish -c "fisher update"
fish -c "fisher --version"
