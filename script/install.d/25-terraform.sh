#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install terraform.
#

if ! command -v "terraform" &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        wget -qO- https://apt.releases.hashicorp.com/gpg | sudo tee /etc/apt/keyrings/hashicorp-keyring.gpg >/dev/null &&
            sudo chmod go+r /etc/apt/keyrings/hashicorp-keyring.gpg &&
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/hashicorp-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null &&
            sudo apt-get update -qq &&
            sudo apt-get install -qq terraform
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    fi
fi

terraform --version
