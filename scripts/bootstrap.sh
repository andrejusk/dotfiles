#!/usr/bin/env bash
set -eo pipefail

NAME=`basename "$0"`
REL_DIR=`dirname "$0"`
ABS_DIR=`readlink -f $REL_DIR/../` # Scripts are nested inside of /scripts

# TODO
# Migrate to config.fish
rm $HOME/.bashrc
rm $HOME/.profile

echo "Stowing $ABS_DIR to $HOME"
stow --dir=$ABS_DIR --target=$HOME files
