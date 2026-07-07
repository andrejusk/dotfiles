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
        git -C "$dest" pull --quiet &
    else
        git clone --depth 1 --quiet "$url" "$dest" &
    fi
done
wait

log_pass "vim plugins configured"
# The plugins target the system vim; it's always present on real machines
# (macOS, Codespaces) but not in the minimal CI containers, so only echo the
# version when vim actually exists — don't abort the install if it doesn't.
if command -v vim &>/dev/null; then
    vim --version 2>/dev/null | sed -n '1p' | log_quote
fi
