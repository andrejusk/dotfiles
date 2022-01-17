#!/usr/bin/env bash

#
# Ensure global node pacakges
# are installed and up to date
#


yarn --version

for dep in $(jq -r ".node_dependencies[]" $CONFIG); do
    if ! grep --silent "$dep" $(yarn global dir)/package.json; then
        yarn --silent global add $dep
    fi
done
yarn --silent global upgrade
