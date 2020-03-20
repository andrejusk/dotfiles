# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# config
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"

# workspace
export WORKSPACE="$HOME/workspace"

# .local
export PATH="$HOME/.local/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"
[ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"

# poetry
export POETRY_ROOT="$HOME/.poetry"
export PATH="$POETRY_ROOT/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
export PATH="$NVM_DIR/bin:$PATH"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
