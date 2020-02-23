#!/bin/bash
#
# Runs all install scripts

# set -xv
set -o pipefail

dir=`dirname $0`
name=`basename $0 ".sh"`
source $dir/utils.sh
printf "${C_CYAN}andrejusk/dotfiles${C_NC}\n\n"

# Check if running
lock_file=$dir/$name.lock
if [ -f $lock_file ]; then
    printf "${C_RED}Script already running${C_NC}\n"
    exit 1
else
    touch $lock_file # Requires clear
fi

# Check for root
if [[ $EUID -ne 0 ]]; then
    printf "${C_RED}Called without sudo, run:${C_NC}\n"
    printf "sudo !!\n\n" 
    make clear
    exit 1
fi

# Run all install scripts
install_dir="$dir/install"
for script in $install_dir/*.sh; 
do 
    script_name=`basename $script ".sh"`
    script_lock="$install_dir/$script_name.lock"
    if [ -f $script_lock ]; then 
        printf "skipping $script_name\n"
    else
        printf "running $script_name\n"
        touch $script_lock
        bash -o pipefail $script | indent
    fi
done

# Exit
make clear
exit 0
