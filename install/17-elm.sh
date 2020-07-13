#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

if not_installed "elm"; then
    npm install -g elm
fi
