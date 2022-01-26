#
# Dots initialisation script:
#  - Sets environment variables
#  - Binds aliases
#


function dots_init {

    # dotfiles
    export DOTS_DIR=${DOTS_DIR:-"$HOME/.dotfiles"}

    # workspace
    export WORKSPACE=${WORKSPACE:-"$HOME/workspace"}
    mkdir -p "$WORKSPACE"

    # xdg data & config
    export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
    mkdir -p "$XDG_DATA_HOME"
    export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
    mkdir -p "$XDG_CONFIG_HOME"

    # local user binaries
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"

    # snap
    export PATH="/snap/bin:$PATH"

    # nvm
    export NVM_DIR=${NVM_DIR:-"$HOME/.nvm"}
    if [ -f "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
    else
        echo "dots warn: $NVM_DIR not found"
    fi

    # node
    export NODE_VERSION=${NODE_VERSION:-"lts/fermium"}
    node_alias="$NVM_DIR/alias/$NODE_VERSION"
    if [ -f "$node_alias" ]; then
        VERSION=$(cat "$node_alias")
        export PATH="$NVM_DIR/versions/node/$VERSION/bin:$PATH"
    else
        echo "dots warn: $node_alias not found"
    fi

    # yarn
    if command -v yarn >/dev/null; then
        export PATH="$(yarn global bin):$PATH"
    fi

    # python
    VENV=$1
    VENV=${VENV:-"3.8.11"}

    # pyenv
    export PYENV_VERSION="$VENV"
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    export WORKON_HOME="$HOME/.cache/pypoetry/virtualenvs"
    if [ -x $(command -v pyenv) ]; then
        eval "$(pyenv init --path)"
    else
        echo "dots warn: pyenv not found"
    fi

    # poetry
    export POETRY_ROOT="$HOME/.poetry"
    export PATH="$POETRY_ROOT/bin:$PATH"

    # z (jump around)
    export Z_DATA_DIR=${Z_DATA:-"$XDG_DATA_HOME/z"}
    export Z_DATA=${Z_DATA:-"$Z_DATA_DIR/data"}
    export Z_OWNER=${Z_OWNER:-$USER}

    # nix
    export NIX_PATH="$HOME/.nix-defexpr/channels"
    if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
        . $HOME/.nix-profile/etc/profile.d/nix.sh
    fi
    if [ -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
        . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
    fi

    # WSL-specific X11 forwarding support
    if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
        export DISPLAY=$(awk '/nameserver/ {print $2}' /etc/resolv.conf):0.0
    fi

    # emacs support
    if test -n "$EMACS"; then
        export SHELL=$(command -v bash)
        export TERM=eterm-color
    fi

    # Machine-specific overrides
    if [ -e $HOME/.profile.local ]; then
        source $HOME/.profile.local
    fi
}

# Ensure dots only initialise once
if [ -z "${DOTS_LOCK}" ]; then
    export DOTS_LOCK=1
    dots_init
fi
