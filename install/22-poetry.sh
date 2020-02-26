#!/usr/bin/env bash
#
# After running this script:
#   1. poetry is installed
#

# 1. poetry is installed
if not_installed "poetry"; then

    printf "Installing poetry...\n"

    # Install poetry
    run https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py python3

fi
printf "poetry is installed\n"
