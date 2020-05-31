if [ -z "$PROFILE_LOCK" ]; then
    export PROFILE_LOCK=1

    # set PATH so it includes user's private bin if it exists
    if [ -d "$HOME/bin" ]; then
        export PATH="$HOME/bin:$PATH"
    fi
    if [ -d "$HOME/.local/bin" ]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # config
    if [ -z "$XDG_DATA_HOME" ]; then
        export XDG_DATA_HOME="$HOME/.local/share"
        mkdir -p "$XDG_DATA_HOME"
    fi
    if [ -z "$XDG_CONFIG_HOME" ]; then
        export XDG_CONFIG_HOME="$HOME/.config"
        mkdir -p "$XDG_CONFIG_HOME"
    fi

    # workspace
    if [ -z "$WORKSPACE" ]; then
        export WORKSPACE="$HOME/workspace"
        mkdir -p "$WORKSPACE"
    fi

    # pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    if [ -d "$PYENV_ROOT" ]; then
        export PATH="$PYENV_ROOT/bin:$PATH"
        export PATH="$PYENV_ROOT/shims:$PATH"
        [ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
    fi

    # poetry
    export POETRY_ROOT="$HOME/.poetry"
    if [ -d "$POETRY_ROOT" ]; then
        export PATH="$POETRY_ROOT/bin:$PATH"
    fi

    # nvm
    export NVM_DIR="$XDG_CONFIG_HOME/nvm"
    if [ -d "$NVM_DIR" ]; then
        export PATH="$NVM_DIR/bin:$PATH"
        # [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    fi

    # yarn
    export YARN_DIR="$HOME/.yarn"
    if [ -d "$YARN_DIR" ]; then
        export PATH="$YARN_DIR/bin:$PATH"
    fi

fi
