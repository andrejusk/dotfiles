#!/usr/bin/env bash

# ssh key exists
ssh_target="$HOME/.ssh"
ssh_key="$ssh_target/id_rsa"
ssh_pub="$ssh_key.pub"
if [ ! -f "$ssh_key" ]; then
    echo "generating ssh key..."
    ssh-keygen -t rsa -b 4096 -f "$ssh_key"
fi
echo "ssh key exists"

# ssh dotfiles are symlinked
ssh_source="$dotfiles_dir/ssh"
link_folder "$ssh_source" "$ssh_target"
echo "ssh dotfiles are symlinked"
cat "$ssh_pub"
