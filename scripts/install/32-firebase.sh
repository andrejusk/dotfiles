#!/usr/bin/env bash
if not_installed "firebase"; then
    run "https://firebase.tools" "bash"
fi

echo "firebase is installed, upgrading..."
curl -sL firebase.tools | upgrade=true bash
firebase --version
