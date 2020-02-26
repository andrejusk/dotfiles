#!/usr/bin/env bash
#
# Script to set up dotfiles repository and run installer.
#
# Installs git using apt-get if not in $PATH.
# Pulls latest dotfiles repository.
#
#
# Usage:
#
#   i. Run in new bash shell.
#
#       $ bash bootstrap.sh
#       $ bash /path/to/bootstrap.sh
#       $ wget path.to/bootstrap.sh -qO - | bash
#
#   ii.  Source into existing bash shell.
#
#       $ source bootstrap.sh
#       $ source /path/to/bootstrap.sh
#       $ source <(wget -q path.to/bootstrap.sh)
#
#
# Configuration:
#
#   $REPOSITORY - GitHub repository to clone
#       @default "andrejusk/dotfiles"
#
#   $WORKSPACE  - parent directory to clone repository into
#       @default "$HOME/workspace"
#
#   $INSTALLER  - installer file name
#       @default "install.sh"
#
#
set -o pipefail
echo "setting up..."

# Variables: $REPOSITORY
if [ -z "$REPOSITORY" ]; then export REPOSITORY="andrejusk/dotfiles"; fi
readonly repository_url="https://github.com/$REPOSITORY.git"
echo "using repository: $repository_url"

# Variables: $WORKSPACE
if [ -z "$WORKSPACE" ]; then export WORKSPACE="$HOME/workspace"; fi
readonly dotfiles_dir="$WORKSPACE/dotfiles"
echo "using dir: $dotfiles_dir"

# Variables: $INSTALLER
if [ -z "$INSTALLER" ]; then export INSTALLER="install.sh"; fi
readonly installer="$dotfiles_dir/$INSTALLER"
echo "using installer: $installer"

# Ensure git is installed
if ! [ -x "$(command -v git)" ]; then
    echo "installing git..."
    sudo apt-get update -qqy
    sudo apt-get install git -qqy
fi

# Ensure repository is up to date
echo "pulling latest..."
if [[ ! -d $dotfiles_dir ]]; then
    mkdir -p "$dotfiles_dir"
    git clone -q "$repository_url" "$dotfiles_dir"
else
    git --git-dir="$dotfiles_dir/.git" pull -q origin master || true
fi

# Install dotfiles
cd "$dotfiles_dir"
chmod +x "$installer"
"$installer"
