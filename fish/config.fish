# Pyenv
setenv PYENV_ROOT "$HOME/.pyenv"
setenv PATH "$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

# Poetry
set -gx PATH $HOME/.poetry/bin $PATH

# Wipe greeting
set fish_greeting
