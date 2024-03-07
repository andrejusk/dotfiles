# /bin/bash

# -----------------------------------------------------------------------------
# Description:
#   Install GitHub CLI.
#

if ! command -v gh &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
        sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
            sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
            sudo apt update &&
            sudo apt install gh -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install gh
    fi
fi
