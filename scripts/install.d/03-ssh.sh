#!/usr/bin/env bash
ssh_target="$HOME/.ssh"
ssh_key="$ssh_target/id_ed25519"
ssh_pub="$ssh_key.pub"
if [ ! -f "$ssh_key" ]; then
    ssh-keygen -t ed25519 -f "$ssh_key"
fi

cat "$ssh_pub"
