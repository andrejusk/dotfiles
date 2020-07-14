#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

if not_installed "gcloud"; then
    echo "Installing gcloud..."
    # Add the Cloud SDK distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    # Import the Google Cloud Platform public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    update
    install google-cloud-sdk
    refresh
fi

gcloud --version
