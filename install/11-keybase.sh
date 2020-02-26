#!/bin/bash
#
# After running this script:
#   1. keybase is installed
#

# 1.keybase is installed
if [ ! hash fish ] 2>/dev/null; then

    printf "Installing keybase...\n"

    curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
    sudo apt install ./keybase_amd64.deb
    run_keybase

fi
