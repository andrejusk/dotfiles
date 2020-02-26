#!/usr/bin/env bash
#
# After running this script:
#   1. docker is installed
#   2. docker-compose if installed
#   3. docker group exists
#   4. user is in docker group
#

# 1. docker is installed
if not_installed "docker"; then

    printf "Installing docker...\n"

    # Requirements
    install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    # Add repository
    add_key https://download.docker.com/linux/ubuntu/gpg
    sudo add-apt-repository -y \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    update

    # Install
    install docker-ce

fi
printf "docker is installed\n"
docker --version

# 2. docker-compose if installed
if not_installed "docker-compose"; then

    printf "Installing docker-compose...\n"

    # Docker-compose
    readonly docker_compose_url="https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m)"
    curl -L docker_compose_url -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

fi
printf "docker-compose is installed\n"
docker-compose --version

# 3. docker group exists
readonly docker_group='docker'
if ! grep -q "$docker_group" /etc/group; then
    sudo groupadd "$docker_group"
fi
printf "group '$docker_group' is created\n"

# 4. user is in docker group
if ! groups "$USER" | grep -q "\b$docker_group\b"; then
    sudo usermod -aG docker "$USER"
fi
printf "user '$USER' is in '$docker_group' group\n"
