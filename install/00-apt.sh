#!/usr/bin/env bash
#
# apt update and upgrade
#
# Install list of packages in ./00-apt-pkglist
#

# apt update, upgrade if not fast
update
if [ -z "$FAST_MODE" ]; then
    upgrade
fi

# Package installs
readonly package_list_file="$install_dir/00-apt-pkglist"
install_file $package_list_file

# Log version
cat /etc/os-release
