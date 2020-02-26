#!/bin/bash
#
# Always updates apt, upgrades apt, and installes 00-apt-pkglist
#

# apt update and upgrade non-interactively
sudo apt-get update -y
DEBIAN_FRONTEND=noninteractive sudo apt-get \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" upgrade -y

# Package installs
pkglist=$(cat $install_dir/00-apt-pkglist)
sudo apt-get install -y $pkglist
