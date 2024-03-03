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
    )

    sudo apt-get update
    sudo apt-get install -qq "${apt_packages[@]}"
    sudo apt-get autoremove
    sudo apt-get autoclean

    unset apt_packages
fi
