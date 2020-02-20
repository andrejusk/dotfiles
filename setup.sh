#!/bin/bash
CYAN='\033[0;36m'
NC='\033[0m'
echo "${CYAN}andrejusk/dotfiles${NC}"

if [[ $EUID -ne 0 ]]; then
    echo "sudo !!" 
    exit 1
fi

install_dir="$0/install"
state_dir="$install_dir/.state"
for script in $install_dir/*.sh; do sh $script; done
