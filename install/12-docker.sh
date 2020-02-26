#!/bin/bash
#
# After running this script:
#   1. docker is installed
#   2. docker-compose if installed
#   3. docker group exists
#   4. user is in docker group
#

# 1. docker is installed
if ! hash docker 2>/dev/null; then

    printf "Installing docker...\n"

    # Requirements
    sudo apt-get -y install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    # Add repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    sudo apt-get -y update

fi
printf "docker is installed\n"

# 2. docker-compose if installed
if ! hash docker-compose 2>/dev/null; then

    printf "Installing docker-compose...\n"

    # Docker-compose
    curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker-compose --version

fi
printf "docker-compose is installed\n"

# 3. docker group exists
group='docker'
if ! grep -q $group /etc/group; then
    sudo groupadd docker
fi
printf "group '$group' is created\n"

# 4. user is in docker group
if ! groups $USER | grep -q "\b$group\b"; then
    sudo usermod -aG docker $USER
fi
printf "user '$USER' is in '$group' group\n"
