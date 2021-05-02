#!/usr/bin/env bash
if [ ! -d ~/.emacs.d ]; then
    echo "Cloning spacemacs"
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
fi
