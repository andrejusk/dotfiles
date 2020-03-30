#!/usr/bin/env bash

# git dotfiles are symlinked
git_source="$dotfiles_dir/git"
git_target="$HOME"
link_folder "$git_source" "$git_target"
printf "git dotfiles linked\n"
git --version
