#!/usr/bin/env bash
#
# After running this script:
#   1. ssh key exists
#   2. ssh dotfiles are symlinked
#

# 1. ssh key exists
readonly ssh_target="$HOME/.ssh"
readonly ssh_key="$ssh_target/id_rsa"
readonly ssh_pub="$ssh_key.pub"
if [ ! -f "$ssh_key" ]; then
    printf "generating ssh key...\n"
    ssh-keygen -t rsa -b 4096 -f "$ssh_key"
fi
printf "ssh key exists\n"

# 2. ssh dotfiles are symlinked
readonly ssh_source="$dotfiles_dir/ssh"
link_folder "$ssh_source" "$ssh_target"
printf "ssh dotfiles are symlinked\n"
cat "$ssh_pub"
