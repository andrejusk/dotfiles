#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

bash_source="$dotfiles_dir/bash"
bash_target="$HOME"
link_folder "$bash_source" "$bash_target"
echo "bash dotfiles are linked"

sudo chmod -R 0644 /etc/update-motd.d/

bash --version
