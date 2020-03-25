#!/usr/bin/env bash

# apt clean, update, upgrade
clean
update
upgrade

# Install list of packages in 00-apt-pkglist
package_list_file="$install_dir/00-apt-pkglist"
install_file "$package_list_file"

# Log OS version
cat /etc/os-release
