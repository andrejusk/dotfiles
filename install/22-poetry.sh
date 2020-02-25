#!/bin/bash
#
# After running this script:
#   1. poetry is installed
#

# 1. poetry is installed
if ! hash poetry 2>/dev/null
then

    printf "Installing poetry...\n"

    # Install poetry
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3

fi
printf "poetry is installed\n"
