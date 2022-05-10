#!/usr/bin/env bash
set -eo pipefail

#
# Install system dependencies in specified config,
# run all post-install scripts contained in a subdirectory
#


TIME=$(date)
HOST=$(hostname)
UUID=${UUID:-$(uuidgen)}

NAME=$(basename "$0")
REL_DIR=$(dirname "$0")
ABS_DIR=$(readlink -f $REL_DIR/../) # Scripts are nested inside of /scripts

UTILS="${REL_DIR}/_utils.sh"
CONFIG="${REL_DIR}/config.json"
SETUP_DIR="${REL_DIR}/setup.d"

# Prevent running as root
if [[ $EUID -eq 0 ]]; then
    echo "Fatal: Running as sudo. Please run as user"
    exit 1
fi

# Initialise log
LOG_DIR="${ABS_DIR}/logs"
mkdir -p $LOG_DIR
LOG_TARGET=${LOG_TARGET:-"${LOG_DIR}/${UUID}.log"}
touch $LOG_TARGET

# Prevent concurrent runs
LOCK_PATH="${ABS_DIR}/.dotlock"
if [ -f $LOCK_PATH ]; then
    echo "Fatal: ${LOCK_PATH} present. Please finish previous run"
    exit 1
else
    # File-based lock prompts user for sudo password
    # before handing session over to install script
    sudo touch $LOCK_PATH
fi
trap "sudo rm -f ${LOCK_PATH}" EXIT

install() {
    echo "Running as ${USER} on ${HOST} (runID ${UUID})"

    # Load installer dependencies
    echo "Sourcing utility script..."
    source $UTILS

    echo "Verifying core apt dependencies are up-to-date..."
    update
    install jq # Required for parsing config file
    install $(jq -r ".apt_core_dependencies[]" "$CONFIG")

    # Add apt repositories
    echo "Verifying apt repositories are present... "
    for i in $(jq ".apt_repositories | keys | .[]" "$CONFIG"); do
        add_repository "$(jq -r ".apt_repositories[$i]" "$CONFIG")"
    done
    update

    # Install apt dependencies
    install $(jq -r ".apt_dependencies[]" "$CONFIG")

    # Install dotfiles on system and load them
    figlet -c "Installing..."
    for i in $(jq ".stow_packages | keys | .[]" "$CONFIG"); do
        stow_package "$(jq -r ".stow_packages[$i]" "$CONFIG")"
    done
    source "$HOME/.profile"

    # Run setup scripts
    figlet -c "Setting up..."
    for script in $SETUP_DIR/*.sh; do
        figlet -c "$(basename $script)"
        source $script
    done
}

echo "${NAME}: Logging to ${LOG_TARGET}"
install 2>&1 | tee $LOG_TARGET
