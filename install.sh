#!/bin/bash
#
# Invokes all install scripts.
#

# Log execution
printf "Installing ${C_CYAN}$repository${C_NC}"
printf " as ${C_YELLOW}$USER${C_NC}\n\n"

# Prevent running as root
if [ "$USER" == "root" ]; then
    printf "Failed: ${C_RED}Running as $USER${C_NC}\n"
    printf "Please run as user, not ${C_YELLOW}sudo${C_NC}\n"
    exit 1
fi

# Prevent concurrent scripts
lock_file="$dotfiles_dir/.$lock_extension"
if [ -f "$lock_file" ]; then
    printf "Failed: ${C_RED}Script already running${C_NC}\n"
    printf "Please wait for script to exit or ${C_YELLOW}make clean${C_NC}\n"
    exit 1
fi
touch $lock_file # Requires clear

# Run all install scripts
for script in "$dotfiles_dir/install/*.sh"; do

    printf "$script\n\n"

    # Avoid pattern matching self
    [ -e "$script" ] || continue

    # Log execution
    script_name=$(basename "$script" ".sh")
    printf "Running ${C_YELLOW}$script_name${C_NC}...\n${C_DGRAY}"

    # Run and indent output
    source "$script" | indent
    printf "${C_NC}\n"

done

# Clean up and exit
printf "Done! Cleaning up...\n${C_DGRAY}"
make clean
printf "${C_NC}\n"
exit 0
