#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install Redis.
#

if ! command -v redis-client &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
        sudo apt-get install -qq redis
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install redis
    fi
fi