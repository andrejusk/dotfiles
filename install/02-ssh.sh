#!/usr/bin/env bash
#
# After running this script:
#   1. ssh-keygen is run # TODO
#   2. ssh dotfiles are symlinked
#

# 1. ssh dotfiles are symlinked
readonly ssh_source="$dotfiles_dir/ssh"
readonly ssh_target="$HOME/.ssh"
link_folder "$ssh_source" "$ssh_target"
printf "ssh dotfiles are symlinked\n"
cat "$ssh_target/id_rsa.pub"
