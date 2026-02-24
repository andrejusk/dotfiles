#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install vim plugins using native vim packages (pack/).
#

vim_pack_dir="$HOME/.vim/pack/plugins/start"
mkdir -p "$HOME/.vim/pack/plugins/start"

vim_plugins=(
    "https://github.com/airblade/vim-gitgutter.git"
    "https://github.com/tpope/vim-commentary.git"
    "https://github.com/tpope/vim-surround.git"
)

for url in "${vim_plugins[@]}"; do
    name=$(basename "$url" .git)
    dest="$vim_pack_dir/$name"
    if [[ -d "$dest" ]]; then
        git -C "$dest" pull --quiet
        log_pass "$name updated"
    else
        git clone --depth 1 --quiet "$url" "$dest"
        log_pass "$name installed"
    fi
done
