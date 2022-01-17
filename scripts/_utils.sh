#!/usr/bin/env bash

#
# Utility functions for common tasks
#

# @arg $1 URL to download
# @arg $2 Path to file
function download_file {
    curl \
        --silent \
        --show-error \
        --location \
        --output $2 \
        $1
}

# @arg $1 URL to run
# @arg $2 binary to use
function download_run {
    file=$(mktemp)
    download_file $1 $file
    cat $file | $2
}

# @arg $1 binary to test
function bin_in_path {
    command -v $1
}


function clean {
    sudo apt-get clean --yes && sudo apt-get autoremove --yes
}

function update {
    sudo apt-get update --yes
}

# @arg $@ apt package(s) to install
function install {
    sudo apt-get install --yes --no-install-recommends $@
}

# @arg $1 package list file to install
# Lines beginning with hash are ignored
function install_file {
    grep -vE '^#' $1 | xargs \
        sudo apt-get install --yes --no-install-recommends
}

# Add apt repository
# @arg $1 JSON object containing the following keys
#   * idnetifier - id for use in filenames
#   * repository - apt repository
#   * signingKey - gpg signing key url
#   * components - apt components
function add_repository {
    id=$(jq -r ".identifier" <<<"$1")
    repository=$(jq -r ".repository" <<<"$1")
    signing_key=$(jq -r ".signingKey" <<<"$1")
    components=$(jq -r ".components" <<<"$1")

    source_file="/etc/apt/sources.list.d/${id}.list"
    sudo touch "$source_file"

    gpg_file="/etc/apt/trusted.gpg.d/${id}.gpg"
    sudo touch "$gpg_file"

    if ! grep -q "^deb .*${repository}" "$source_file"; then
        curl -fsSL "$signing_key" | gpg --dearmor | sudo tee "$gpg_file" >/dev/null
        source="deb [arch=$(dpkg --print-architecture)] ${repository} ${components}"
        echo "$source" | sudo tee "$source_file" >/dev/null
    fi
}

# @arg $1 JSON object containing the following keys
#   * name - apt repository
#   * target - gpg signing key url
function stow_package {
    name=$(jq -r ".name" <<<"$1")
    target=$(jq -r ".target" <<<"$1")

    case $target in
    HOME)
        rm -f $HOME/.bashrc
        rm -f $HOME/.profile
        target=$HOME
        ;;
    *) ;;

    esac

    echo "Stowing $ABS_DIR/files/$name to $target"
    sudo stow --dir="$ABS_DIR/files" --target=$target $name
}
