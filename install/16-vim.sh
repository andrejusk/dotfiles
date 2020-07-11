#!/usr/bin/env bash

vim_source="$dotfiles_dir/vim"
vim_target="$XDG_CONFIG_HOME/nvim"
link_folder "$vim_source" "$vim_target"
echo "vim dotfiles are linked"

mkdir -p "$XDG_DATA_HOME/nvim/backup"
plug_target="$XDG_DATA_HOME/nvim/site/autoload/plug.vim"
if [ ! -f $plug_target ]; then
    curl -fLo "$plug_target" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

pip3 install neovim
node --version
yarn global add neovim
sudo gem install neovim

nvim -E PlugInstall -c q
nvim -E PluginInstall -c q
nvim --version

