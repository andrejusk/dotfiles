#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

if not_installed "kubectl"; then
    echo "Installing kubectl..."
    sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2

    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

    update

    install kubectl
    refresh
fi
