#!/usr/bin/env bash
function apt_update {
    sudo apt-get update
}

# @arg $1 debian package to install if not present
function apt_install {
    if ! dpkg -s $1; then
        sudo apt-get install -y $1
    fi
}

# ---------------------------------------------------------------------------- #
#	Helper functions
# ---------------------------------------------------------------------------- #
clean() {
    sudo apt-get clean
}

update() {
    apt_update
}

# @arg $1 packages to install
install() {
    apt_install $1
    refresh
}

# @arg $1 package list file to install
install_file() {
    sudo apt-get install -qqyf $(cat $1)
    refresh
}

# @arg $1 repository to add
add_ppa() {
    sudo add-apt-repository -y ppa:$1
}

# @arg $1 url to add
# @arg $2 keyring to add to
add_key() {
    curl -fsSL $1 \
        | sudo gpg --no-default-keyring --keyring $2 --import -
}

# @arg $1 URL to run
# @arg $2 binary to use
run() {
    curl -fsSL $1 | $2
}

# Symlink contents of source folder to target
#
# @arg $1 source folder
# @arg $2 target folder
link_folder() {
    mkdir -p $2
    cp -srf $1/. $2
}

# @arg $1 binary to test
not_installed() {
    ! [ -x "$(command -v $1)" ]
}

# Refreshes PATH
refresh() {
    hash -r
}

# Add to PATH and refresh
# @arg $1 path to add to PATH
add_path() {
    export PATH="$1:$PATH"
    refresh
}
