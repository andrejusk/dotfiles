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

    apt_packages=($(comm -13 <(printf "%s\n" "${apt_packages[@]}" | sort) <(dpkg --get-selections | awk '{print $1}' | sort)))
    if [ ${#apt_packages[@]} -gt 0 ]; then
        sudo apt-get install -qq "${apt_packages[@]}"
    fi

    unset apt_packages
fi
