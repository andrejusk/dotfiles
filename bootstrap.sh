#!/usr/bin/env bash
#
# Script to set up and run dotfiles installer
#
#   Installs git using `apt-get` if not in $PATH
#       step may be skipped, 
#       @see $FAST_MODE
#
#   Pulls latest target repository using git 
#       @see $REPOSITORY
#
#   Creates workspace if one doesn't already exist 
#       @see $WORKSPACE
#
#   Runs installer 
#       @see $INSTALLER
#
#
# Usage
#
#   i.  Run script
#
#       $ ./bootstrap.sh
#       $ /path/to/bootstrap.sh
#
#   ii. Download and run script
#
#       a.  non-interactively
#           $ wget path.to/bootstrap.sh -qO - | bash
#
#       b. interactively
#           $ bash <(wget -qO- path.to/bootstrap.sh)
#
#
# Configuration
#
#   $REPOSITORY - GitHub repository to clone
#                 @default "andrejusk/dotfiles"
#
#   $WORKSPACE  - parent directory to clone repository into
#                 @default "$HOME/workspace"
#
#   $INSTALLER  - installer file name
#                 @default "install.sh"
#
#   $FAST_MODE  - whether to skip git (and speed up install steps)
#                 @defualt false
#
#
set -o pipefail
echo "setting up..."

# Variables: $REPOSITORY
if [ -z "$REPOSITORY" ]; then
    export REPOSITORY="andrejusk/dotfiles"
fi
export repository_url="https://github.com/$REPOSITORY.git"
echo "using repository: $repository_url"

# Variables: $WORKSPACE
if [ -z "$WORKSPACE" ]; then
    export WORKSPACE="$HOME/workspace"
fi
export dotfiles_dir="$WORKSPACE/dotfiles"
echo "using dir: $dotfiles_dir"

# Variables: $INSTALLER
if [ -z "$INSTALLER" ]; then 
    export INSTALLER="install.sh"; 
fi
export installer="$dotfiles_dir/$INSTALLER"
echo "using installer: $installer"

# Pull latest git if not skipped
if [ -z "$FAST_MODE" ]; then

    # Set to falsy variable
    export FAST_MODE=false

    # Ensure git is installed
    if ! [ -x "$(command -v git)" ]; then
        echo "installing git..."
        sudo apt-get update -qqy
        sudo apt-get install git -qqy
    fi

    # Ensure latest is pulled
    echo "pulling latest..."
    if ! [ -d "$dotfiles_dir" ]; then
        mkdir -p "$dotfiles_dir"
        git clone -q "$repository_url" "$dotfiles_dir"
    else
        git --git-dir="$dotfiles_dir/.git" fetch -q
        git --git-dir="$dotfiles_dir/.git" rebase -q --autostash FETCH_HEAD
    fi

fi

# Install dotfiles
echo "installing..."
cd "$dotfiles_dir"
chmod +x "$installer"
"$installer"
echo "done!"
