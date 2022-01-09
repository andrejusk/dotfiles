#!/usr/bin/env bash
yarn --version

for dep in $(jq -r ".node_dependencies[]" $CONFIG); do
    if grep --silent "$dep" $(yarn global dir)/package.json
    then
        yarn --silent global upgrade $dep
    else
        yarn --silent global add $dep
    fi
done
