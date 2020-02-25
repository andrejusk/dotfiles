#!/bin/bash
#
# Script to set up and install dotfiles repository.
#
# Usage:
#   `source path/to/bootstrap.sh`
#   `source <(wget path/to/bootstrap.sh)`
#
set -o pipefail
echo "setting up..."

# Variables: git
if [ -z "$REPOSITORY" ]; then
    export REPOSITORY="andrejusk/dotfiles"
fi
readonly repository_url="https://github.com/$REPOSITORY.git"
echo "using repository: $repository_url"

# Variables: workspace
if [ -z "$WORKSPACE" ]; then
    export WORKSPACE="$HOME/workspace"
fi
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
source "$dotfiles_dir/install.sh"
