#!/bin/bash

apt-add-repository -y ppa:fish-shell/release-3
apt update
apt-get -y install fish
chsh -s `which fish`
