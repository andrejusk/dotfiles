# ---------------------------------------------------------------------------- #
#   Cross-shell
# ---------------------------------------------------------------------------- #

# config
set XDG_CONFIG_HOME $HOME/.config

# workspace
set WORKSPACE $HOME/workspace

# .local
set -x PATH $HOME/.local/bin $PATH

# pyenv
set PYENV_ROOT $HOME/.pyenv
set -x PATH $PYENV_ROOT/bin $PATH
set -x PATH $PYENV_ROOT/shims $PATH
type -q pyenv && pyenv init - | source

# poetry
set POETRY_ROOT $HOME/.poetry
set -x PATH $POETRY_ROOT/bin $PATH

# nvm
set NVM_ROOT $HOME/.nvm
set -x PATH $NVM_ROOT/bin $PATH

# yarn
set YARN_DIR $HOME/.yarn
set -x PATH $YARN_DIR/bin $PATH

# ---------------------------------------------------------------------------- #
#   Fish specific
# ---------------------------------------------------------------------------- #

# Wipe greeting
set fish_greeting
