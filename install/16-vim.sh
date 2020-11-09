#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

mkdir -p "$XDG_DATA_HOME/nvim/backup"
plug_target="$XDG_DATA_HOME/nvim/site/autoload/plug.vim"
if [ ! -f $plug_target ]; then
    echo "Downloading vim-plug to $plug_target";
    curl -fLo "$plug_target" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Installing neovim support";
pip3 install --user neovim pynvim 'python-language-server[all]'
yarn global add neovim
sudo gem install neovim

echo "Running PlugInstall";
nvim --headless +UpdateRemotePlugins +PlugClean! +PlugInstall +PlugUpgrade +PlugUpdate +qall
nvim --version
