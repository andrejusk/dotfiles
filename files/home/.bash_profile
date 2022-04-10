[ -f "$HOME/.profile" ] && source "$HOME/.profile"

eval "$(pyenv init -)"
export PATH="$HOME/.poetry/bin:$PATH"
