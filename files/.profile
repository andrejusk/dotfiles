if [ -z "$PROFILE_LOCK" ]; then
    export PROFILE_LOCK=1

    # set PATH so it includes user's private bin
    export PATH="$HOME/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"

    # xdg data & config
    if [ -z "$XDG_DATA_HOME" ]; then
        export XDG_DATA_HOME="$HOME/.local/share"
    fi
    mkdir -p "$XDG_DATA_HOME"
    if [ -z "$XDG_CONFIG_HOME" ]; then
        export XDG_CONFIG_HOME="$HOME/.config"
    fi
    mkdir -p "$XDG_CONFIG_HOME"

    # workspace
    if [ -z "$WORKSPACE" ]; then
        export WORKSPACE="$HOME/workspace"
    fi
    mkdir -p "$WORKSPACE"

    # pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    export PATH="$PYENV_ROOT/shims:$PATH"
    if [ -d "$PYENV_ROOT" ]; then
        [ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
    fi

    # poetry
    export POETRY_ROOT="$HOME/.poetry"
    export PATH="$POETRY_ROOT/bin:$PATH"

    # nvm
    if [ -z "$NVM_DIR" ]; then
   	export NVM_DIR="$HOME/.nvm"
    fi
    mkdir -p "$NVM_DIR"
    export PATH="$NVM_DIR/bin:$PATH"

    # yarn
    export YARN_DIR="$HOME/.yarn"
    mkdir -p "$YARN_DIR"
    export PATH="$YARN_DIR/bin:$PATH"

fi
