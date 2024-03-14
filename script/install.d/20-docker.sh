#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS) Install Docker.
#   (Linux) Setup Docker.
#

if [[ -z "$SKIP_DOCKER_CONFIG" ]]; then
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
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v docker &> /dev/null; then
            brew install --cask docker
        fi
    fi
fi
