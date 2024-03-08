#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install terraform.
#

if ! command -v "terraform" &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform
        wget -O- https://apt.releases.hashicorp.com/gpg |
            gpg --dearmor |
            sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
            https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
            sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update -qq &&
            sudo apt-get install -qq terraform
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    fi
fi

terraform --version
