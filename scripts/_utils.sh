#!/usr/bin/env bash
# Utility functions for common tasks

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

# @arg $1 apt package to test
function apt_installed {
    dpkg --status $1 >/dev/null
}

function clean {
    sudo apt-get clean -qq
}

function update {
    sudo apt-get update -qq
}

# @arg $1 apt package to install if not present
function install {
    if ! apt_installed $1; then
        sudo apt-get install -qq $1
    fi
}

# Add apt repository
# @arg $1 JSON object containing the following keys
#   * repository - apt repository
#   * signingKey - gpg signing key url
#   * components - apt components
function add_repository {
    source_file="/etc/apt/sources.list.d/dots.list"
    repository=$(jq -r ".repository" <<<"$1")
    if [ ! -f "$source_file" ]; then
        touch $source_file
    fi
    if ! grep -q "^deb .*${repository}" "$source_file"; then
        signingKey=$(jq -r ".signingKey" <<<"$1")
        components=$(jq -r ".components" <<<"$1")
        curl -fsSL $signingKey | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/dots.gpg > /dev/null
        source="deb [arch=$(dpkg --print-architecture)] ${repository} ${components}"
        echo $source | sudo tee $source_file > /dev/null
    fi
}

# @arg $1 package list file to install
function install_file {
    sudo apt-get install -qqf $(cat $1)
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
