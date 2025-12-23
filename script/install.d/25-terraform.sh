#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install terraform.
#

if ! command -v terraform &>/dev/null; then
    case "$DOTS_PKG" in
        apt)
            terraform_keyring_path="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
            if [[ ! -f "$terraform_keyring_path" ]]; then
                curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o "$terraform_keyring_path"
            fi
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
                https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
                sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt-get update -qq &&
                sudo apt-get install -qq terraform
            ;;
        pacman)
            sudo pacman -S --noconfirm terraform
            ;;
        brew)
            brew tap hashicorp/tap
            brew install hashicorp/tap/terraform
            ;;
        *)
            log_warn "Skipping Terraform install: no supported package manager found"
            ;;
    esac
fi

terraform --version
