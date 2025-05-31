#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install Redis.
#

if ! command -v redis-client &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        redis_keyring_path="/usr/share/keyrings/redis-archive-keyring.gpg"
        if [[ ! -f "$redis_keyring_path" ]]; then
            curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o "$redis_keyring_path"
        fi
        echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" \
            | sudo tee /etc/apt/sources.list.d/redis.list > /dev/null
        sudo apt-get install -qq redis
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install redis
    fi
fi