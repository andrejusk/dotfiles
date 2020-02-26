#!/bin/bash
#
# After running this script:
#   1. fish shell is installed
#   2. fish shell is default login shell
#   3. fish dotfiles are symlinked
#

# 1. fish shell is installed
if [ ! hash fish ] 2>/dev/null; then

    printf "Installing fish...\n"

    # Add fish repository
    sudo apt-add-repository -y ppa:fish-shell/release-3
    sudo apt-get -y update

    # Install fish
    sudo apt-get -y install fish

fi
printf "fish is installed\n"

# 2. fish shell is default login shell
fish_path=$(which fish)
if [ $SHELL != fish_path ]; then

    printf "Setting fish as default...\n"

    # Update default login shell
    chsh -s $fish_path $USER
    usermod -s $fish_path $USER

fi
printf "fish is default login shell\n"

# 3. fish dotfiles are symlinked
target="$HOME/.config/fish"
for file in $(ls -d $script_dir/fish/*); do
    rel_path=$(realpath --relative-to="$target" "$file")
    printf "Linking $file to $target as $rel_path...\n"
    ln -sv $rel_path $target
done
printf "fish dotfiles linked\n"
