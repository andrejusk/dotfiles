#!/usr/bin/env bash
#
# After running this script:
#   1. fish shell is installed
#   2. fish shell is default login shell
#   3. fish dotfiles are symlinked
#   4. fisher is installed
#

# 1. fish shell is installed
if not_installed "fish"; then

    printf "Installing fish...\n"

    # Add fish repository
    add_ppa "fish-shell/release-3"
    update

    # Install fish
    install fish

fi
printf "fish is installed\n"
fish --version

# 2. fish shell is default login shell
current_shell="$(getent passwd $USER | cut -d: -f7)"
fish_path="$(which fish)"
if [ "$current_shell" != "$fish_path" ]; then

    printf "setting fish as default, current shell was $current_shell\n"

    # Update default login shell
    sudo chsh -s "$fish_path" "$USER"
    sudo usermod -s "$fish_path" "$USER"

fi
printf "fish is default login shell\n"

# 3. fish dotfiles are symlinked
fish_source="$dotfiles_dir/fish"
fish_target="$XDG_CONFIG_HOME/fish"
link_folder "$fish_source" "$fish_target"
printf "fish dotfiles linked\n"

# 4. fisher is installed
fisher_location="$XDG_CONFIG_HOME/fish/functions/fisher.fish"
if ! [ -f "$fisher_location" ]; then

    printf "Installing fisher...\n"

    # Install fisher
    curl https://git.io/fisher --create-dirs -sLo "$fisher_location"

fi
printf "fisher is installed, updating...\n"
fish -c "fisher"
fish -c "fisher --version"
