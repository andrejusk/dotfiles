#!/usr/bin/env bash

vim_source="$dotfiles_dir/vim"
vim_target="$XDG_CONFIG_HOME/nvim"
link_folder "$vim_source" "$vim_target"
echo "vim dotfiles are linked"

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
	       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
nvim -E PlugInstall -c q

nvim --version

