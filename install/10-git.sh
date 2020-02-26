#!/bin/bash
#
# After running this script:
#   1. git dotfiles are symlinked
#

# 1. git dotfiles are symlinked
target="$HOME"
for file in $(ls -d $script_dir/git/*); do
    rel_path=$(realpath --relative-to="$target" "$file")
    printf "Linking $file to $target as $rel_path...\n"
    ln -sv $rel_path $target
done
printf "git dotfiles linked\n"
