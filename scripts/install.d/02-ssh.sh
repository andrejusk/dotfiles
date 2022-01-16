#!/usr/bin/env bash

#
# Ensure ssh key is generated, log public key
#


ssh_target="$HOME/.ssh"
ssh_key="$ssh_target/id_rsa"
ssh_pub="$ssh_key.pub"
if [ ! -f "$ssh_key" ]; then
    echo "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$ssh_key"
else
    echo "SSH key is already present"
fi

cat "$ssh_pub"
