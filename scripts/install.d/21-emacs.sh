#!/usr/bin/env bash

#
# Ensure spacemacs configuration layer is checked out
#


if [ ! -d ~/.emacs.d ]; then
    echo "Cloning spacemacs"
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
else
    echo "spacemacs already present"
fi
emacs --version
