# Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval (pyenv init -)
eval (pyenv virtualenv-init -)

# Poetry
set -gx PATH $HOME/.poetry/bin $PATH

# Wipe greeting
set fish_greeting
