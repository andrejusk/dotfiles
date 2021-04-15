#!/usr/bin/env bash
set -eo pipefail

#
# Script that stows all tracked dotfiles into the user's home directory.
#

REL_DIR=`dirname "$0"`
ABS_DIR=`readlink -f $REL_DIR/../` # Scripts are nested inside of /scripts

# TODO
# Migrate to config.fish
rm $HOME/.bashrc
rm $HOME/.profile

echo "Stowing $ABS_DIR to $HOME"
stow --dir=$ABS_DIR --target=$HOME files
