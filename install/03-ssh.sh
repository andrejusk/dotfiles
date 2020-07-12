#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

# ssh key exists
ssh_target="$HOME/.ssh"
ssh_key="$ssh_target/id_rsa"
ssh_pub="$ssh_key.pub"
if [ ! -f "$ssh_key" ]; then
    echo "generating ssh key..."
    ssh-keygen -t rsa -b 4096 -f "$ssh_key"
fi
echo "ssh key exists"

cat "$ssh_pub"
