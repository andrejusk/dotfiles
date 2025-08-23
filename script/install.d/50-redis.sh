#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install Redis.
#

if ! command -v redis-cli &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            redis_keyring_path="/usr/share/keyrings/redis-archive-keyring.gpg"
            if [[ ! -f "$redis_keyring_path" ]]; then
                curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o "$redis_keyring_path"
            fi
            echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" \
                | sudo tee /etc/apt/sources.list.d/redis.list > /dev/null
            sudo apt-get install -qq redis
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm redis
        else
            log_warn "Skipping Redis install: no supported package manager found"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install redis
    fi
fi

redis-cli --version
