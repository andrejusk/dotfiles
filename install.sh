#!/bin/bash
#
# Invokes all install scripts.
#
set -euo pipefail

source "$dotfiles_dir/utils.sh"
printf "Installing ${C_CYAN}$REPOSITORY${C_NC}"
printf " as ${C_YELLOW}$USER${C_NC}\n\n"

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
touch "$install_lock_file" # Requires clean

# Run all install scripts
readonly install_dir="$dotfiles_dir/install"
readonly script_filter="$install_dir/*.sh"
for script in "$script_filter"; do

    # Avoid pattern matching self
    [ -e "$script" ] || continue

    # Log execution
    script_name="$(basename "$script" ".sh")"
    printf "Running ${C_YELLOW}$script_name${C_NC}...\n${C_DGRAY}"

    # Run and indent output
    source "$script" | indent
    printf "${C_NC}"

done

# Clean up and exit
printf "Done! Cleaning up...\n${C_DGRAY}"
make clean
printf "${C_NC}\n"
exit 0
