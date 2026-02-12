#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install Redis.
#

# Skip in Codespaces (project-specific tool)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_skip "Codespaces"; return 0; }

if ! command -v redis-cli &>/dev/null; then
    case "$DOTS_PKG" in
        apt)
            redis_keyring_path="/usr/share/keyrings/redis-archive-keyring.gpg"
            if [[ ! -f "$redis_keyring_path" ]]; then
                curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o "$redis_keyring_path"
            fi
            echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" \
                | sudo tee /etc/apt/sources.list.d/redis.list > /dev/null
            sudo apt-get install -qq redis
            ;;
        pacman)
            sudo pacman -S --noconfirm redis
            ;;
        brew)
            brew install redis
            ;;
        *)
            log_warn "Skipping Redis install: no supported package manager found"
            ;;
    esac
fi

redis-cli --version
log_pass "Redis installed"
