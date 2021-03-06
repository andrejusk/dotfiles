#!/usr/bin/env bash
set -eo pipefail

#
# Script that installs system dependencies specified in a config,
# and runs all post-install scripts contained in a subdirectory.
#

TIME=${TIME:-$(date)}
UUID=${UUID:-$(uuidgen)}
HOST=${HOST:-$(hostname)}

NAME=$(basename "$0")
REL_DIR=$(dirname "$0")
ABS_DIR=$(readlink -f $REL_DIR/../) # Scripts are nested inside of /scripts

UTILS="${REL_DIR}/_utils.sh"
CONFIG="${REL_DIR}/install_config.json"
INSTALL_DIR="${REL_DIR}/install.d"

LOG_DIR="${ABS_DIR}/logs"
mkdir -p "$LOG_DIR"
LOG_TARGET=${LOG_TARGET:-"${LOG_DIR}/${UUID}.log"}

install() {
    echo "Running $NAME at $TIME"
    echo "Running as $USER on $HOST"

    # Prevent running as root
    if [[ $EUID -eq 0 ]]; then
        echo "Failed: Running as sudo. Please run as user"
        exit 1
    fi

    # Load installer dependencies
    source "$UTILS"
    update
    install jq
    for dep in $(jq -r ".apt_core_dependencies[]" "$CONFIG"); do
        install "$dep"
    done

    # Add apt repositories
    for i in $(jq ".apt_repositories | keys | .[]" "$CONFIG"); do
        value=$(jq -r ".apt_repositories[$i]" "$CONFIG")
        add_repository "$value"
    done
    update

    # Install apt dependencies
    for dep in $(jq -r ".apt_dependencies[]" "$CONFIG"); do
        install "$dep"
    done

    # Install dotfiles on system and load them
    figlet -c "Stowing..."
    for i in $(jq ".stow_packages | keys | .[]" "$CONFIG"); do
        value=$(jq -r ".stow_packages[$i]" "$CONFIG")
        stow_package "$value"
    done
    source "$HOME/.profile"

    # Run custom installer scripts
    figlet -c "Installing..."
    for script in $INSTALL_DIR/*.sh; do
        figlet -c "$(basename $script)"
        source $script
    done
}

echo "install: Logging to $LOG_TARGET"
install 2>&1 | tee "$LOG_TARGET"
