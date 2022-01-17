#!/usr/bin/env bash

#
# Run docker post-installation setup
#


docker --version

# Ensure current user has appropriate permissions
readonly docker_group="docker"
if ! grep -q "$docker_group" /etc/group; then
    echo "Adding docker group"
    sudo groupadd "$docker_group"
else
    echo "Docker group already present"
fi

if ! groups "$USER" | grep -q "\b$docker_group\b"; then
    echo "Adding user to docker group"
    sudo usermod -aG docker "$USER"
else
    echo "User already present in docker group"
fi
