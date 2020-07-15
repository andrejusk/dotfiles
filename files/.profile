if [ -z "$PROFILE_LOCK" ]; then
    export PROFILE_LOCK=1

    # set PATH so it includes user's private bin
    export PATH="$HOME/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"

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
    export PATH="$PYENV_ROOT/bin:$PATH"
    export PATH="$PYENV_ROOT/shims:$PATH"
    if [ -d "$PYENV_ROOT" ]; then
        [ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
    fi

    # poetry
    export POETRY_ROOT="$HOME/.poetry"
    export PATH="$POETRY_ROOT/bin:$PATH"

    # nvm
    export NVM_DIR="$XDG_CONFIG_HOME/nvm"
    export PATH="$NVM_DIR/bin:$PATH"

    # yarn
    export YARN_DIR="$HOME/.yarn"
    export PATH="$YARN_DIR/bin:$PATH"

fi
