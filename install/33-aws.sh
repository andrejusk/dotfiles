#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip -d "$dotfiles_dir/tmp"
rm awscliv2.zip

if not_installed "aws"; then
    echo "Installing awscli..."
    sudo ./tmp/aws/install
fi

echo "awscli is installed, upgrading..."
sudo ./tmp/aws/install --update
aws --version

rm -rf ./tmp/aws
