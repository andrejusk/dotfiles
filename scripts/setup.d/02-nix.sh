#!/usr/bin/env bash

#
# Ensure nix is installed
#


if ! bin_in_path "nix"; then
    echo "Installing nix..."
    download_run "https://nixos.org/nix/install" "sh"
    source $HOME/.nix-profile/etc/profile.d/nix.sh
else
    echo "nix is present"
fi
nix --version

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh

home-manager build
