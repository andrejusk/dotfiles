#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (distros with pacman only) Install core pacman packages.
#

if command -v pacman &> /dev/null; then
    pacman_packages=(
        ca-certificates
        curl
        gnupg
        wget
        base-devel
    )

    sudo pacman -Sy --noconfirm
    sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

    unset pacman_packages

    pacman --version
else
    log_warn "Skipping: pacman not found"
fi
