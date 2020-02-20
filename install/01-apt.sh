#!/bin/bash
GREY='\033[0;37m'
NC='\033[0m'
echo "${GREY}andrejusk/dotfiles/apt${NC}"

sudo apt-get update
sudo apt-get upgrade -y
