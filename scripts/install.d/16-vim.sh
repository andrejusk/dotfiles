#!/usr/bin/env bash

# Install neovim from unstable debian repo
if ! bin_in_path "nvim"; then
    curl -fsSL "https://ftp-master.debian.org/keys/archive-key-10.asc" | sudo apt-key add -
    echo "deb http://deb.debian.org/debian unstable main" \
        | sudo tee /etc/apt/sources.list.d/unstable.list
    echo "Package: neovim
    Pin: release a=unstable
    Pin-Priority: 900" \
        | sudo tee /etc/apt/preferences.d/neovim
    update
    install neovim
fi

mkdir -p "$XDG_DATA_HOME/nvim/backup"
plug_dir="$XDG_DATA_HOME/nvim/site/autoload"
mkdir -p "$plug_dir"
plug_target="$plug_dir/plug.vim"
if [ ! -f $plug_target ]; then
    download_file \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
        "$plug_target"
fi

nvim --headless +UpdateRemotePlugins +PlugClean! +PlugInstall +PlugUpgrade +PlugUpdate +qall
nvim --version
