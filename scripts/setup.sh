#!/usr/bin/env bash
set -eo pipefail

#
# Script that checks out a compatible dotfiles repository
# and runs the installer to set up a new installation.
#

author=${GITHUB_AUTHOR:-andrejusk}
repository=${GITHUB_REPOSITORY:-dotfiles}
branch=${GITHUB_BRANCH:-master}
echo "Using repository $author/$repository at $branch"

setup_dir=${DOTFILES_DIR:-$HOME/.dotfiles}

# Prevent overwriting existing installation
mkdir -p $setup_dir
if [[ -z $(ls -A $setup_dir) ]]; then
    echo "Setting up $setup_dir"
else
    echo "Failed: Setup directory not empty $setup_dir"
    exit 1
fi

# Download and untar repo
tmp_dir=`mktemp -d`
tmp_dest="$tmp_dir/dotfiles.tar.gz"
wget "https://github.com/$author/$repository/archive/$branch.tar.gz" -qO $tmp_dest
tar -C $tmp_dir -zxf $tmp_dest
mv $tmp_dir/$repository-$branch/* $setup_dir
rm -rf $tmp_dir

echo "Done!"
$setup_dir/scripts/install.sh
