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
#       $ bash path/to/bootstrap.sh
#       $ wget -O - path.to/bootstrap.sh | bash
#
#   ii.  Source into existing bash shell.
#
#       $ source bootstrap.sh
#       $ source path/to/bootstrap.sh
#       $ source <(wget path.to/bootstrap.sh)
#
#
# Configuration:
#
#   $REPOSITORY - GitHub repository to clone and run $dir/install.sh of
#       @default "andrejusk/dotfiles"
#
#   $WORKSPACE  - parent directory to clone repository in to
#       @default "$HOME/workspace"
#
#
set -o pipefail
echo "setting up..."

# Variables: git
if [ -z "$REPOSITORY" ]; then export REPOSITORY="andrejusk/dotfiles"; fi
readonly repository_url="https://github.com/$REPOSITORY.git"
echo "using repository: $repository_url"

# Variables: workspace
if [ -z "$WORKSPACE" ]; then export WORKSPACE="$HOME/workspace"; fi
readonly dotfiles_dir="$WORKSPACE/dotfiles"
echo "using dir: $dotfiles_dir"

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
cd $dotfiles_dir
source "$dotfiles_dir/install.sh"
