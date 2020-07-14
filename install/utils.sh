#!/usr/bin/env bash
# ---------------------------------------------------------------------------- #
#	Helper functions
# ---------------------------------------------------------------------------- #
clean() {
    sudo apt-get clean
}

update() {
    sudo apt-get update
}

# Non-interactive upgrade
upgrade() {
    DEBIAN_FRONTEND=noninteractive \
        sudo apt-get \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        -y \
        dist-upgrade
    sudo apt-get -y autoremove
}

# @arg $1 packages to install
install() {
    sudo apt-get install -qqy $1
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
add_key() {
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true \
        curl -fsSL $1 \
        | sudo apt-key add -
}

# @arg $1 URL to run
# @arg $2 binary to use
run() {
    curl -fsSL $1 | $2 | indent
}

# Symlink contents of source folder to target
#
# @arg $1 source folder
# @arg $2 target folder
link_folder() {
    mkdir -p $2
    cp -srf $1/. $2
}

indent() { sed 's/^/  /'; }

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

export -f clean update upgrade install install_file add_ppa add_key run \
    link_folder indent not_installed refresh add_path

# ---------------------------------------------------------------------------- #
#	Shell colours
# ---------------------------------------------------------------------------- #

C_BLACK='\033[0;30m'
C_DGRAY='\033[1;30m'
C_RED='\033[0;31m'
C_LRED='\033[1;31m'
C_GREEN='\033[0;32m'
C_LGREEN='\033[1;32m'
C_ORANGE='\033[0;33m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_LBLUE='\033[1;34m'
C_PURPLE='\033[0;35m'
C_LPURPLE='\033[1;35m'
C_CYAN='\033[0;36m'
C_LCYAN='\033[1;36m'
C_LGRAY='\033[0;37m'
C_WHITE='\033[1;37m'
C_NC='\033[0m'

# ---------------------------------------------------------------------------- #
#       Helper variables                                                       #
# ---------------------------------------------------------------------------- #
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
install_dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dotfiles_dir="$(dirname "$install_dir")"
source "$dotfiles_dir/files/.bash_profile"
refresh
