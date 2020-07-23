#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

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

if not_installed "terraform-lsp"; then
    echo "Installing terraform-lsp..."
    wget https://github.com/juliosueiras/terraform-lsp/releases/download/v0.0.11-beta2/terraform-lsp_0.0.11-beta2_linux_amd64.tar.gz
    tar -C "$dotfiles_dir/tmp" -xzf terraform-lsp_0.0.11-beta2_linux_amd64.tar.gz
    rm terraform-lsp_0.0.11-beta2_linux_amd64.tar.gz
    mv "$dotfiles_dir/tmp/terraform-lsp" ~/.local/bin
fi

echo "terraform-lsp is installed"
