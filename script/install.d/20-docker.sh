#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS) Install Docker.
#   (Linux) Setup Docker.
#

# skip if in WSL
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    echo -e "${YELLOW}Running in WSL${NC}"
    export SKIP_DOCKER_CONFIG=1
fi

# skip if in CODESPACES
if [[ -n "$CODESPACES" ]]; then
    echo -e "${YELLOW}Running in GitHub Codespaces${NC}"
    export SKIP_DOCKER_CONFIG=1
fi

# skip on mac
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}Running on macOS${NC}"
    export SKIP_DOCKER_CONFIG=1
fi

if [[ -z "$SKIP_DOCKER_CONFIG" ]]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if ! command -v docker &> /dev/null; then
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update

            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        fi

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
    docker --version
else
    echo -e "${YELLOW}Skipping Docker configuration${NC}"
fi
