#!/usr/bin/env bash
#
# apt update and upgrade
#
# Install list of packages in ./00-apt-pkglist
#

# pre clean
clean

# apt update, upgrade
update
upgrade

# Package installs
package_list_file="$install_dir/00-apt-pkglist"
install_file "$package_list_file"

# Log version
cat /etc/os-release
