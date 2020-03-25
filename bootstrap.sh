#!/usr/bin/env bash
set -o pipefail

# Script to set up dependencies and run installer
#
#   1. Install git using `apt-get` if not already in $PATH
#       * see $FAST_MODE
#
#   2. Create workspace folder if one doesn't already exist 
#       * see $WORKSPACE
#
#   3. Pull latest target repository using `git`
#       * see $REPOSITORY, $FAST_MODE
#
#   4. Run installer 
#       * see $INSTALLER
#
#
# Usage
#
#   i.  Run script
#
#       * $ ./bootstrap.sh
#       * $ /path/to/bootstrap.sh
#
#   ii. Download and run script
#
#       a.  non-interactively
#           * $ wget path.to/bootstrap.sh -qO - | bash
#
#       b. interactively
#           * $ bash <(wget -qO- path.to/bootstrap.sh)
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

echo "setting up..."

# Inistialise variables
if [ -z "$WORKSPACE" ]; then
    export WORKSPACE="$HOME/workspace"
fi
export dotfiles_dir="$WORKSPACE/dotfiles"
echo "using dir: $dotfiles_dir"

if [ -z "$REPOSITORY" ]; then
    export REPOSITORY="andrejusk/dotfiles"
fi
repository_url="git@github.com:$REPOSITORY.git"
echo "using repository: $repository_url"

if [ -z "$INSTALLER" ]; then 
    INSTALLER="install.sh"; 
fi
installer="$dotfiles_dir/$INSTALLER"
echo "using installer: $installer"

# Ensure repo is available
if [ -z "$FAST_MODE" ]; then
    export FAST_MODE=false

    if ! [ -x "$(command -v git)" ]; then
        echo "installing git..."
        sudo apt-get update -qqy
        sudo apt-get install git -qqy
    fi

    echo "pulling latest..."
    if ! [ -d "$dotfiles_dir" ]; then
        mkdir -p "$dotfiles_dir"
        git clone -q "$repository_url" "$dotfiles_dir"
    else
        git --git-dir="$dotfiles_dir/.git" fetch -q
        git --git-dir="$dotfiles_dir/.git" rebase -q --autostash FETCH_HEAD
    fi

fi

# Run installer
echo "installing..."
source "$dotfiles_dir/bash/.profile"
chmod +x "$installer"
"$installer"

echo "done!"
