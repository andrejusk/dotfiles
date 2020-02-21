#!/bin/bash
dir=`dirname "$0"`
source "$dir/colors.sh"
printf "${C_CYAN}andrejusk/dotfiles${C_NC}\n"

# Check if running
lock_file="$dir/setup.lock"
if [ -f "$dir/.lock" ]; then
    printf "${C_RED}Script already running${C_NC}\n"
    exit 1
elif
    touch 
fi

# Check for root
if [[ $EUID -ne 0 ]]; then
    printf "${C_RED}Called without sudo, please run:${C_NC}\n"
    printf "sudo !!\n\n" 
    exit 1
fi

# Run all install scripts
install_dir="$dir/install"
for script in $install_dir/*.sh; 
do 
    if [ -f "$script.lock" ]; then 
        printf "$script\n"
    fi
    printf $script
    # sh $script; 
    
done
