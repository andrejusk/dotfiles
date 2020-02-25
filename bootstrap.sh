#!/bin/bash
#
# Script to set up and install dotfiles repository.
# 
# Usage:
#   `source path/to/bootstrap.sh`
#   `source <(wget path/to/bootstrap.sh)`
#
set -euo pipefail

# Set up variables and imports
readonly repository="andrejusk/dotfiles"
readonly repository_url="https://github.com/$repository.git"
readonly workspace_dir="$HOME/workspace"
readonly dotfiles_dir="$workspace_dir/dotfiles"
readonly install_dir="$dotfiles_dir/install"
readonly lock_file="$dotfiles_dir/.dotlock"
source "$dotfiles_dir/utils.sh"

# Log execution
printf "Setting up ${C_CYAN}$repository${C_NC} with:\n"
printf "  repository:\t  ${C_YELLOW}$repository${C_NC}\n"
printf "  repository_url: ${C_YELLOW}$repository_url${C_NC}\n"
printf "  workspace_dir:  ${C_YELLOW}$workspace_dir${C_NC}\n"
printf "  dotfiles_dir:\t  ${C_YELLOW}$dotfiles_dir${C_NC}\n"
printf "  install_dir:\t  ${C_YELLOW}$install_dir${C_NC}\n"
printf "  lock_file:\t  ${C_YELLOW}$lock_file${C_NC}\n\n"

# Ensure git is installed
if ! hash git 2>/dev/null
then
    sudo apt-get update -yqq
    sudo apt-get install -yqq git
fi

# Ensure repository is cloned
if [[ ! -d "$dotfiles_dir" ]]
then
    mkdir -p "$workspace_dir"
    git clone -q "$repository_url" "$dotfiles_dir"
fi

# Ensure repository is up to date
cd "$dotfiles_dir"
git pull -q origin master || true

# Install dotfiles
source "$dotfiles_dir/install.sh"
