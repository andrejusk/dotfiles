#!/usr/bin/env bash

if not_installed "terraform"; then
    echo "Installing terraform..."
    wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
    unzip terraform_0.12.24_linux_amd64.zip -d "$dotfiles_dir/tmp"
    rm terraform_0.12.24_linux_amd64.zip
    mkdir -p ~/.local/bin
    mv "$dotfiles_dir/tmp/terraform" ~/.local/bin
    rm "$dotfiles_dir/tmp/terraform"
fi

echo "terraform is installed"
terraform --version
