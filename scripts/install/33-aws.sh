#!/usr/bin/env bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
temp_dir=$(mktemp -d)
unzip awscliv2.zip -d "$temp_dir"
rm awscliv2.zip

if not_installed "aws"; then
    echo "Installing awscli..."
    sudo $temp_dir/aws/install
fi

echo "awscli is installed, upgrading..."
sudo $temp_dir/aws/install --update
aws --version
