#!/usr/bin/env bash

# fish shell is installed
if not_installed "fish"; then
    echo "Installing fish..."

    add_ppa "fish-shell/release-3"
    update
    install fish

fi
echo "fish is installed"
fish --version

# fish shell is default login shell
current_shell="$(getent passwd $USER | cut -d: -f7)"
fish_path="$(which fish)"
if [ "$current_shell" != "$fish_path" ]; then
    echo "setting fish as default, current shell was $current_shell"

    sudo chsh -s "$fish_path" "$USER"
    sudo usermod -s "$fish_path" "$USER"
fi
echo "fish is default login shell"

# fish dotfiles are symlinked
fish_source="$dotfiles_dir/fish"
fish_target="$XDG_CONFIG_HOME/fish"
link_folder "$fish_source" "$fish_target"
echo "fish dotfiles linked"

# fisher is installed
fisher_location="$XDG_CONFIG_HOME/fish/functions/fisher.fish"
if ! [ -f "$fisher_location" ]; then

    echo "Installing fisher..."

    # Install fisher
    curl https://git.io/fisher --create-dirs -sLo "$fisher_location"

fi
printf "fisher is installed, updating...\n"
fish -c "fisher"
fish -c "fisher --version"
