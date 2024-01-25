#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (Ubuntu only) Configure docker.
#

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    docker --version

    readonly docker_group="docker"
    if ! grep -q "$docker_group" /etc/group; then
        echo "Adding docker group"
        sudo groupadd "$docker_group"
    fi

    if ! groups "$USER" | grep -q "\b$docker_group\b"; then
        echo "Adding user to docker group"
        sudo usermod -aG docker "$USER"
    fi

    unset docker_group
fi
