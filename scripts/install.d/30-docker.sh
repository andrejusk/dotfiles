#!/usr/bin/env bash
docker --version

readonly docker_group="docker"
if ! grep -q "$docker_group" /etc/group; then
    sudo groupadd "$docker_group"
fi

if ! groups "$USER" | grep -q "\b$docker_group\b"; then
    sudo usermod -aG docker "$USER"
fi
