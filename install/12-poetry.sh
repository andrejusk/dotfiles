#!/usr/bin/env bash
#
# After running this script:
#   1. poetry is installed
#

# 1. poetry is installed
if not_installed "poetry"; then

    printf "Installing poetry...\n"

    # Install poetry
    pip3 install --user poetry

fi
printf "poetry is installed, upgrading...\n"
pip3 install --upgrade poetry
poetry --version
