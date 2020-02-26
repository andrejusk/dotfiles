#!/usr/bin/env bash
#
# Alias commands and utilities.
#

update() {
    sudo apt-get update -y
}

# Non-interactive upgrade
upgrade() {
    DEBIAN_FRONTEND=noninteractive \
        sudo apt-get upgrade -y \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold"
}

# @arg $1 packages to install
install() {
    sudo apt-get install -y $1
}

# @arg $1 repository to add
app_ppa() {
    sudo add-apt-repository -y ppa:$1 &>/dev/null
}

# @arg $1 url to add
add_key() {
    curl -fsSL $1 | sudo apt-key add -
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
    cp -srf $1/. $2
}

indent() { sed 's/^/  /'; }

# @arg $1 binary to test
not_installed() {
    ! [ -x "$(command -v $1)" ]
}

# Colors
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
