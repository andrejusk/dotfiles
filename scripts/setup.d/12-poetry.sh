#!/usr/bin/env bash

#
# Ensure the poetry Python package manager is installed
# and up to date
#


if ! bin_in_path "poetry"; then
    echo "Installing Poetry..."

    # see https://python-poetry.org/docs/#osx--linux--bashonwindows-install-instructions
    download_run \
        "https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py" \
        python -
else
    echo "Poetry already present"
fi

poetry self update
poetry --version
