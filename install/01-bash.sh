#!/usr/bin/env bash

bash_source="$dotfiles_dir/bash"
bash_target="$HOME"
link_folder "$bash_source" "$bash_target"
echo "bash dotfiles are linked"

source "$HOME/.bashrc"
echo "bashrc sourced"

sudo chmod -R 0644 /etc/update-motd.d/

bash --version
