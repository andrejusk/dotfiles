#!/usr/bin/env bash

if not_installed "fish"; then
    echo "installing fish..."
    add_ppa "fish-shell/release-3"
    update
    install fish

fi
echo "fish is installed"

fish_source="$dotfiles_dir/fish"
fish_target="$XDG_CONFIG_HOME/fish"
link_folder "$fish_source" "$fish_target"
echo "fish dotfiles linked"

fish --version

fisher_location="$XDG_CONFIG_HOME/fish/functions/fisher.fish"
if ! [ -f "$fisher_location" ]; then
    echo "Installing fisher..."
    curl https://git.io/fisher --create-dirs -sLo "$fisher_location"
fi
echo "fisher is installed, updating..."
sh -c 'env HOME=$(mktemp -d) fish -c "fisher"'

fish -c "fisher --version"

if not_installed "fishlogin"; then
    echo "setting up fishlogin..."
    mkdir -p ~/bin
    target="$HOME/bin/fishlogin"
    tee -a $target << END
#!/bin/bash -l
exec -l fish "\$@"
END
    sudo chmod +x $target
    echo $target | sudo tee -a /etc/shells
    sudo usermod -s $target $USER
fi
