#!/bin/bash
GREY='\033[0;37m'
NC='\033[0m'
echo "${GREY}andrejusk/dotfiles/docker${NC}"

if grep -q SomeString "$File"; then

elif

fi



sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
 
 sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
