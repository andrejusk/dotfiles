#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install Helm.
#

if ! command -v helm &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # https://helm.sh/docs/intro/install/#from-apt-debianubuntu
        curl -fsSL https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
        sudo apt-get install -qq apt-transport-https
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
        sudo apt-get update -qq
        sudo apt-get install -qq helm
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install helm
    fi
fi

helm version
