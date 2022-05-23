[ -f "$HOME/.profile" ] && source "$HOME/.profile"

eval "$(pyenv init -)"
export PATH="$HOME/.poetry/bin:$PATH"

if [ -e /home/andrejus/.nix-profile/etc/profile.d/nix.sh ]; then . /home/andrejus/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
