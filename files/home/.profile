# U _____ u _   _  __     __
# \| ___"|/| \ |"| \ \   /"/u
#  |  _|" <|  \| |> \ \ / //
#  | |___ U| |\  |u /\ V /_,-.
#  |_____| |_| \_| U  \_/-(_/
#  <<   >> ||   \\,-.//
# (__) (__)(_")  (_/(__)
#

# xdg data & config
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
mkdir -p "$XDG_DATA_HOME"
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
mkdir -p "$XDG_CONFIG_HOME"

# local user binaries
local_bin_path="$HOME/.local/bin"
if [[ ":$PATH:" != *":$local_bin_path:"* ]]; then
    export PATH="$local_bin_path:$PATH"
fi
mkdir -p ~/.local/bin
unset local_bin_path

# homebrew
brew_path="/opt/homebrew/bin/brew"
if [ -x "$brew_path" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
unset brew_path

# workspace
export WORKSPACE=${WORKSPACE:-"$HOME/Workspace"}
mkdir -p "$WORKSPACE"

# dotfiles
export DOTFILES=${DOTFILES:-"$HOME/.dotfiles"}

# nvm
if [ -z "$NVM_DIR" ]; then
    export NVM_DIR=${NVM_DIR:-"$HOME/.nvm"}
    mkdir -p "$NVM_DIR"
fi
[ -f "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# node (default v20 "iron" LTS version)
node_alias="$NVM_DIR/alias/lts/iron"
if [ -f "$node_alias" ]; then
    VERSION=`cat $node_alias`
    if [ -x `command -v nvm` ]; then
        nvm install "$VERSION" > /dev/null 2>&1 & disown
    fi
    node_bin_path="$NVM_DIR/versions/node/$VERSION/bin"
    if [[ ":$PATH:" != *":$node_bin_path:"* ]]; then
        export PATH="$node_bin_path:$PATH"
    fi
fi
unset node_alias node_bin_path VERSION

# pyenv
export PYENV_ROOT=${PYENV_ROOT:-"$HOME/.pyenv"}
pyenv_bin_path="$PYENV_ROOT/bin"
if [[ ":$PATH:" != *":$pyenv_bin_path:"* ]]; then
    export PATH="$pyenv_bin_path:$PATH"
fi
if [ -x `command -v pyenv` ]; then
    eval "$(pyenv init --path)"
fi
unset pyenv_bin_path

# poetry
export POETRY_ROOT=${POETRY_ROOT:-"$HOME/.poetry"}
poetry_bin_path="$POETRY_ROOT/bin"
if [[ ":$PATH:" != *":$poetry_bin_path:"* ]]; then
    export PATH="$poetry_bin_path:$PATH"
fi
unset poetry_bin_path

# z (jump around)
export Z_DATA_DIR=${Z_DATA:-"$XDG_DATA_HOME/z"}
export Z_DATA=${Z_DATA:-"$Z_DATA_DIR/data"}
export Z_OWNER=${Z_OWNER:-$USER}

# nix
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
    . $HOME/.nix-profile/etc/profile.d/nix.sh
fi

#     _       _                    _      ____
# U  /"\  u  |"|        ___    U  /"\  u / __"| u
#  \/ _ \/ U | | u     |_"_|    \/ _ \/ <\___ \/
#  / ___ \  \| |/__     | |     / ___ \  u___) |
# /_/   \_\  |_____|  U/| |\u  /_/   \_\ |____/>>
#  \\    >>  //  \\.-,_|___|_,-.\\    >>  )(  (__)
# (__)  (__)(_")("_)\_)-' '-(_/(__)  (__)(__)
#
alias j="z"
alias fd="command -v fdfind"
alias dots="$DOTFILES/install"
