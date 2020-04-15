#!/usr/bin/env bash

clean
update
upgrade
echo "apt cleaned, updated, upgraded"

package_list_file="$install_dir/00-apt-pkglist"
install_file "$package_list_file"
echo "list of dependencies installed"

cat /etc/os-release
