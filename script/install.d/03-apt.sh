#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (distros with apt only) Install core apt packages.
#

# apt only
[[ "$DOTS_PKG" != "apt" ]] && { log_warn "Skipping: Not using apt"; return 0; }

apt_packages=(
    ca-certificates
    curl
    gnupg
    gnupg2
    wget
)

sudo apt-get update -qq
sudo apt-get install -qq "${apt_packages[@]}"

unset apt_packages

apt --version
