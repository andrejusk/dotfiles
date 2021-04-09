#!/usr/bin/env bash
DOCKER_FOLDER="$HOME/.docker"
if not_installed "docker"; then
    mkdir -p "$DOCKER_FOLDER"

    # Requirements
    install apt-transport-https ca-certificates curl gnupg-agent \
        software-properties-common

    # Add repository
    distro=$(lsb_release -si | tr "[:upper:]" "[:lower:]") # cast to lowercase
    add_key "https://download.docker.com/linux/$distro/gpg" \
        "gnupg-ring:/etc/apt/trusted.gpg.d/docker-apt-key.gpg"
    sudo add-apt-repository -y \
        "deb [arch=amd64] https://download.docker.com/linux/$distro \
        $(lsb_release -cs) \
        stable"
    update

    # Install
    install docker-ce

    # Chown
    sudo chown "$USER":"$USER" "$DOCKER_FOLDER" -R
    sudo chmod g+rwx "$DOCKER_FOLDER" -R

fi
docker --version

if not_installed "docker-compose"; then
    pip3 install --user docker-compose
fi
pip3 install --upgrade docker-compose
docker-compose --version

readonly docker_group="docker"
if ! grep -q "$docker_group" /etc/group; then
    sudo groupadd "$docker_group"
fi

if ! groups "$USER" | grep -q "\b$docker_group\b"; then
    sudo usermod -aG docker "$USER"
fi
