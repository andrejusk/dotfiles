#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (distros with apt only) Install core apt packages.
#

if command -v apt-get &> /dev/null; then
    apt_packages=(
        curl
        gnupg
        gnupg2
        wget
    )

    sudo apt-get update -qq
    sudo apt-get install -qq "${apt_packages[@]}"

    unset apt_packages
else
    echo "Skipping: apt-get not found"
fi

apt --version
