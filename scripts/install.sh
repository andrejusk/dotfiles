#!/usr/bin/env bash
set -eo pipefail

TIME=${TIME:-`date`}
UUID=${UUID:-`uuidgen`}
HOST=${HOST:-`hostname`}

NAME=`basename "$0"`
REL_DIR=`dirname "$0"`
ABS_DIR=`readlink -f $REL_DIR/../` # Scripts are nested inside of /scripts

LOG_DIR="$ABS_DIR/logs"
mkdir -p $LOG_DIR
LOG_TARGET=${LOG_TARGET:-$LOG_DIR/$UUID.log}


main() {
    echo "Running $NAME at $TIME"
    echo "Running as $USER on $HOST"

    # Prevent running as root
    if [[ $EUID -eq 0 ]]; then
        echo "Failed: Running as sudo. Please run as user"
        exit 1
    fi

    echo "Loading utils"
    source $REL_DIR/_utils.sh

    apt_update

    echo "Installing jq..."
    apt_install jq

    echo "Installing apt dependencies..."
    for dep in `jq -r ".apt_dependencies[]" $ABS_DIR/config.json`; do
        apt_install $dep
    done

    figlet -c "bootstrapping..."
    $ABS_DIR/scripts/bootstrap.sh
    source $HOME/.profile

    figlet -c "installing..."
    export INSTALL_DIR="$REL_DIR/install"
    for script in $INSTALL_DIR/*.sh; do
        figlet -c `basename $script`
        source $script
    done

}

echo "main: Logging to $LOG_TARGET"
main 2>&1 |tee $LOG_TARGET
