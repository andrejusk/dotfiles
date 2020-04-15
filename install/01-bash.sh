#!/usr/bin/env bash

bash_source="$dotfiles_dir/bash"
bash_target="$HOME"
link_folder "$bash_source" "$bash_target"
echo "bash dotfiles are linked"

bash --version
