#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS) Install Docker.
#   (Linux) Setup Docker.
#

# skip if SKIP_DOCKER_CONFIG is set
[[ -n "$SKIP_DOCKER_CONFIG" ]] && { log_warn "Skipping: SKIP_DOCKER_CONFIG is set"; return 0; }

# skip if in WSL
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    log_warn "Skipping: Running in WSL"
    return 0
fi

# skip if in Codespaces
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

# skip on macOS
[[ "$DOTS_OS" == "macos" ]] && { log_warn "Skipping: macOS"; return 0; }

if ! command -v docker &> /dev/null; then
    case "$DOTS_PKG" in
        apt)
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update

            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        pacman)
            sudo pacman -S --noconfirm --needed docker docker-buildx docker-compose
            ;;
        *)
            log_warn "Skipping Docker install: no supported package manager found"
            ;;
    esac
fi

readonly docker_group="docker"
if ! grep -q "$docker_group" /etc/group; then
    log_info "Adding docker group"
    sudo groupadd "$docker_group"
fi

if ! groups "$USER" | grep -q "\b$docker_group\b"; then
    log_info "Adding user to docker group"
    sudo usermod -aG docker "$USER"
fi

docker --version
