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

    sudo apt-get update -qq
    if [ ${#apt_packages[@]} -gt 0 ]; then
        sudo apt-get install -qq "${apt_packages[@]}"
    fi

    unset apt_packages
else
    echo "Skipping: apt-get not found"
fi

apt --version
echo "Last updated: $(ls -l /var/lib/apt/periodic/update-success-stamp | awk '{print $6" "$7" "$8}')"
