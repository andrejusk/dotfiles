#!/bin/bash

apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" upgrade
apt-get -y autoremove
apt-get -y autoclean
