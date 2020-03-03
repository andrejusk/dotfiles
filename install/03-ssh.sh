#!/usr/bin/env bash
#
# After running this script:
#   1. ssh key exists
#   2. ssh dotfiles are symlinked
#

# 1. ssh key exists
ssh_target="$HOME/.ssh"
ssh_key="$ssh_target/id_rsa"
ssh_pub="$ssh_key.pub"
if [ ! -f "$ssh_key" ]; then
    printf "generating ssh key...\n"
    ssh-keygen -t rsa -b 4096 -f "$ssh_key"
fi
printf "ssh key exists\n"

# 2. ssh dotfiles are symlinked
ssh_source="$dotfiles_dir/ssh"
link_folder "$ssh_source" "$ssh_target"
printf "ssh dotfiles are symlinked\n"
cat "$ssh_pub"