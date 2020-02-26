#!/usr/bin/env bash
#
# After running this script:
#   1. keybase is installed
#

# 1.keybase is installed
if not_installed "keybase"; then

    printf "Installing keybase...\n"

    curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
    install ./keybase_amd64.deb
    rm ./keybase_amd64.deb

fi
printf "keybase is installed\n"
keybase --version
