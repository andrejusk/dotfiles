# Load .profile, containing login, non-bash related initializations.
[ -f "$HOME/.profile" ] && source "$HOME/.profile"

command -v mise &>/dev/null && eval "$(mise activate bash)"
