# =============================================================================
#
# Dots initialisation script
#
# =============================================================================

# -----------------------------------------------------------------------------
# Machine-specific overrides
if [ -e $HOME/.profile.local ]; then
    source $HOME/.profile.local
fi

# -----------------------------------------------------------------------------
# dotfiles
export DOTS_DIR=${DOTS_DIR:-"$HOME/.dotfiles"}

# -----------------------------------------------------------------------------
# workspace
export WORKSPACE=${WORKSPACE:-"$HOME/workspace"}
mkdir -p "$WORKSPACE"

# -----------------------------------------------------------------------------
# xdg data & config
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
mkdir -p "$XDG_DATA_HOME"
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
mkdir -p "$XDG_CONFIG_HOME"

# -----------------------------------------------------------------------------
# local user binaries
LOCAL_PATH="$HOME/.local/bin"
mkdir -p $LOCAL_PATH
if [[ ! $PATH == *$LOCAL_PATH* ]]; then
    export PATH="$LOCAL_PATH:$PATH"
fi

# -----------------------------------------------------------------------------
# snap
SNAP_PATH="$"
if [[ ! $PATH == *$SNAP_PATH* ]]; then
    export PATH="$SNAP_PATH:$PATH"
fi

# -----------------------------------------------------------------------------
# nvm
export NVM_DIR=${NVM_DIR:-"$HOME/.nvm"}
if [ -f "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
else
    echo "dots warn: '$NVM_DIR' not found"
fi

# -----------------------------------------------------------------------------
# node
export NODE_VERSION=${NODE_VERSION:-"lts/fermium"}
node_alias="$NVM_DIR/alias/$NODE_VERSION"
if [ -f "$node_alias" ]; then
    VERSION=$(cat "$node_alias")
    if [[ ! $PATH == *$VERSION* ]]; then
        export PATH="$NVM_DIR/versions/node/$VERSION/bin:$PATH"
    fi

    # FIXME better dependency
    # -------------------------------------------------------------------------
    # yarn
    if command -v yarn >/dev/null; then
        YARN_PATH=$(yarn global bin)
        if [[ ! $PATH == *$YARN_PATH* ]]; then
            export PATH="$YARN_PATH:$PATH"
        fi
    fi
else
    echo "dots warn: '$node_alias' not found"
fi

# -----------------------------------------------------------------------------
# python
VENV=${VENV:-"3.10.2"}

# -----------------------------------------------------------------------------
# pyenv
export PYENV_VERSION="$VENV"
export PYENV_ROOT="$HOME/.pyenv"
if [[ ! $PATH == *$PYENV_ROOT* ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi
export WORKON_HOME="$HOME/.cache/pypoetry/virtualenvs"
if [ -x $(command -v pyenv) ]; then
    eval "$(pyenv init --path)"
fi

# -----------------------------------------------------------------------------
# poetry
export POETRY_ROOT="$HOME/.poetry"
if [[ ! $PATH == *$POETRY_ROOT* ]]; then
    export PATH="$POETRY_ROOT/bin:$PATH"
fi

# -----------------------------------------------------------------------------
# z (jump around)
export Z_DATA_DIR=${Z_DATA:-"$XDG_DATA_HOME/z"}
export Z_DATA=${Z_DATA:-"$Z_DATA_DIR/data"}
export Z_OWNER=${Z_OWNER:-$USER}

# -----------------------------------------------------------------------------
# nix
export NIX_PATH="$HOME/.nix-defexpr/channels"
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
    . $HOME/.nix-profile/etc/profile.d/nix.sh
fi
if ! [ -z "${__HM_SESS_VARS_SOURCED}" ] && [ -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
    . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
fi

# -----------------------------------------------------------------------------
# WSL-specific X11 forwarding support
if grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null; then
    export DISPLAY=$(awk '/nameserver/ {print $2}' /etc/resolv.conf):0.0
fi
# TODO sys32 PATH

export PATH="$HOME/.poetry/bin:$PATH"
