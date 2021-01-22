#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

if not_installed "fish"; then
    echo "installing fish..."
    add_ppa "fish-shell/release-3"
    update
    install fish
fi

echo "fish is installed"
fish --version

fisher_location="$XDG_CONFIG_HOME/fish/functions/fisher.fish"
if ! [ -f "$fisher_location" ]; then
    echo "Installing fisher..."
    curl https://git.io/fisher --create-dirs -sLo "$fisher_location"
fi
echo "fisher is installed, updating..."
fish -c "fisher update";

fish -c "fisher --version"

if not_installed "fishlogin"; then
    echo "setting up fishlogin..."
    mkdir -p ~/bin
    target="$HOME/bin/fishlogin"

    tee -a $target << END
#!/bin/bash
exec -l fish "\$@"
END

    sudo chmod +x $target
    echo $target | sudo tee -a /etc/shells
    sudo usermod -s $target $USER
fi
