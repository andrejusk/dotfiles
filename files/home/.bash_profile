# Load .profile, containing login, non-bash related initializations.
[ -f "$HOME/.profile" ] && source "$HOME/.profile"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

eval "$(pyenv init -)"
