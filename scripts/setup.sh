#!/usr/bin/env bash
set -eo pipefail

# GitHub repository details
AUTHOR=${AUTHOR:-andrejusk}
REPOSITORY=${REPOSITORY:-dotfiles}
BRANCH=${BRANCH:-master}
echo "Using repository $AUTHOR/$REPOSITORY at $BRANCH"

# Target folder to checkout to
DOTFILES_DIR=${DOTFILES_DIR:-$HOME/.dotfiles}
mkdir -p $DOTFILES_DIR
if [ -z `ls -A $DOTFILES_DIR` ]; then
    echo "Setting up $DOTFILES_DIR"
else
    echo "Failed: Setup directory not empty $DOTFILES_DIR"
    exit 1
fi

# Download and untar repo
tmp_dir=`mktemp -d`
tmp_dest="$tmp_dir/dotfiles.tar.gz"
wget "https://github.com/$AUTHOR/$REPOSITORY/archive/$BRANCH.tar.gz" -qO $tmp_dest
tar -C $tmp_dir -zxf $tmp_dest
mv $tmp_dir/$REPOSITORY-$BRANCH/* $DOTFILES_DIR
rm -rf $tmp_dir

echo "Done!"
$DOTFILES_DIR/scripts/install.sh
