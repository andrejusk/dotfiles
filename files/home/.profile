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

export PATH="$HOME/.local/bin:$PATH"
mkdir -p ~/.local/bin

# workspace
export WORKSPACE=${WORKSPACE:-"$HOME/workspace"}
mkdir -p "$WORKSPACE"

# dotfiles
export DOTFILES=${DOTFILES:-"$HOME/.dotfiles"}


# nvm
if [ -z "$NVM_DIR" ]; then
    export NVM_DIR=${NVM_DIR:-"$HOME/.nvm"}
    mkdir -p "$NVM_DIR"
    [ -f "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
fi

# node (default v14)
node_alias="$NVM_DIR/alias/lts/fermium"
if [ -f "$node_alias" ]; then
    VERSION=`cat $node_alias`
    nvm install "$VERSION" > /dev/null 2>&1 & disown
    export PATH="$NVM_DIR/versions/node/$VERSION/bin:$PATH"
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if [ -x `command -v pyenv` ]; then
    eval "$(pyenv init --path)"
fi

# poetry
export POETRY_ROOT="$HOME/.poetry"
export PATH="$POETRY_ROOT/bin:$PATH"


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
alias fd=`command -v fdfind`
