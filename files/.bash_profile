# Load .profile, containing login, non-bash related initializations.
[ -f "$HOME/.profile" ] && source "$HOME/.profile"

# Load .bashrc, containing non-login related bash initializations.
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"


# References:
# https://unix.stackexchange.com/questions/192521/loading-profile-from-bash-profile-or-not-using-bash-profile-at-all
# https://www.stefaanlippens.net/my_bashrc_aliases_profile_and_other_stuff/
if [ -e /home/andrejus/.nix-profile/etc/profile.d/nix.sh ]; then . /home/andrejus/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
