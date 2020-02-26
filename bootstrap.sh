#!/bin/bash
#
# Script to set up and install dotfiles repository.
# 
# Usage:
#   `source path/to/bootstrap.sh`
#   `source <(wget path/to/bootstrap.sh)`
#
set -euf -o pipefail

# Set up variables and imports
repository="andrejusk/dotfiles"
repository_url="https://github.com/$repository.git"
workspace_dir="$HOME/workspace"
dotfiles_dir="$workspace_dir/dotfiles"
lock_extension="dotlock"
source "${dotfiles_dir}/utils.sh"

# Ensure git is installed
if ! hash git 2>/dev/null; then
    sudo apt-get update -yqq
    sudo apt-get install -yqq git
fi

# Ensure repository is cloned
if [[ ! -d $dotfiles_dir ]]; then
    mkdir -p $workspace_dir
    git clone $repository_url $dotfiles_dir
fi

# Ensure repository is up to date
cd $dotfiles_dir
# git pull origin master

# Install dotfiles
source $dotfiles_dir/install.sh
