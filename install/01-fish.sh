#!/usr/bin/env bash
#
# After running this script:
#   1. fish shell is installed
#   2. fish shell is default login shell
#   3. fish dotfiles are symlinked
#

# 1. fish shell is installed
if not_installed "fish"; then

    printf "Installing fish...\n"

    # Add fish repository
    app_ppa fish-shell/release-3
    update

    # Install fish
    install fish

fi
printf "fish is installed\n"
fish --version

# 2. fish shell is default login shell
readonly fish_path="$(which fish)"
if [ "$SHELL" != fish_path ]; then

    # Update default login shell
    sudo chsh -s "$fish_path" "$USER"
    sudo usermod -s "$fish_path" "$USER"

fi
printf "fish is default login shell\n"

# 3. fish dotfiles are symlinked
readonly fish_source="$dotfiles_dir/fish"
readonly fish_target="$HOME/.config/fish"
link_folder "$fish_source" "$fish_target"
printf "fish dotfiles linked\n"
