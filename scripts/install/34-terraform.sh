#!/usr/bin/env bash
tf_version="0.14.6"
if not_installed "terraform"; then
    echo "Installing terraform..."
    tf_archive="terraform_${tf_version}_linux_amd64.zip"
    wget "https://releases.hashicorp.com/terraform/${tf_version}/${tf_archive}"
    unzip "$tf_archive" -d "$dotfiles_dir/tmp"
    rm "$tf_archive"
    mkdir -p ~/.local/bin
    mv "$dotfiles_dir/tmp/terraform" ~/.local/bin
    rm "$dotfiles_dir/tmp/terraform"
fi

echo "terraform is installed"
terraform --version

tf_lsp_version="0.13.0"
if not_installed "terraform-ls"; then
    echo "Installing terraform-ls..."
    tf_lsp_archive="terraform-ls_${tf_lsp_version}_linux_amd64.zip"
    wget "https://releases.hashicorp.com/terraform-ls/${tf_lsp_version}/${tf_lsp_archive}"
    unzip "${tf_lsp_archive}" -d "$dotfiles_dir/tmp"
    rm "${tf_lsp_archive}"
    mkdir -p ~/.local/bin
    mv "$dotfiles_dir/tmp/terraform-ls" ~/.local/bin
    rm "$dotfiles_dir/tmp/terraform-ls"
fi

echo "terraform-lsp is installed"
