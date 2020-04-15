#!/usr/bin/env bash
set -eo pipefail

export install_dir="$dotfiles_dir/install"
source "$install_dir/utils.sh"
printf "\nInstalling ${C_CYAN}$REPOSITORY${C_NC}"
printf " as ${C_YELLOW}$USER${C_NC}\n"

# Prevent running as root
if [[ $USER == root ]]; then
    printf "Failed: ${C_RED}Running as root${C_NC}\n"
    printf "Please run as user, not ${C_YELLOW}sudo${C_NC}\n"
    exit 1
fi

# Prevent concurrent runs
readonly install_lock_file="$dotfiles_dir/.dotlock"
if [ -f "$install_lock_file" ]; then
    printf "Failed: ${C_RED}Script already running${C_NC}\n"
    printf "Please wait for script to exit or ${C_YELLOW}make clean${C_NC}\n"
    exit 1
fi
touch "$install_lock_file"

# Install all scripts by default
if [ -z "$TARGET" ]; then
    export TARGET="all"
fi

if [ "$TARGET" == "all" ]; then
    scripts=($install_dir/*.sh)
else
    scripts=($install_dir/*-{bash,$TARGET}.sh)
fi
for script in "${scripts[@]}"; do

    script_name="$(basename $script .sh)"
    IFS='-' read -a script_fields <<<"$script_name"
    script_number=${script_fields[0]}
    script_target=${script_fields[1]}

    printf "\nRunning #$script_number ${C_YELLOW}$script_target${C_NC}...\n${C_DGRAY}"
    chmod +x "$script"
    source "$HOME/.bashrc" && "$script" | indent
    printf "${C_NC}"

# Clean up if fails
done || make clean

printf "\nDone! Cleaning up...\n${C_DGRAY}"
make clean
printf "${C_NC}\n"
exit 0
