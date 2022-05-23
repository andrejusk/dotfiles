#!/usr/bin/env bash

#
# Ensure ssh key is generated, log public key
#

METHOD="ed25519"

ssh_target="$HOME/.ssh"
ssh_key="${ssh_target}/id_${METHOD}"
ssh_pub="${ssh_key}.pub"
if [ ! -f "$ssh_key" ]; then
    ssh-keygen -a 100 -t $METHOD -f "$ssh_key"
fi

cat "$ssh_pub"
