#!/usr/bin/env bash
#
# After running this script:
#   1. bash dotfiles are symlinked
#

# 1. bash dotfiles are symlinked
readonly bash_source="$dotfiles_dir/bash"
readonly bash_target="$HOME"
link_folder "$bash_source" "$bash_target"
printf "bash dotfiles are linked\n"
