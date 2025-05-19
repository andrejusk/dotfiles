#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure Node.js.
#

NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

nvm_version="0.39.7"
if ! command -v "nvm" &>/dev/null; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh)"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
fi

nvm --version
nvm alias default lts/jod
nvm install lts/jod
nvm use lts/jod

echo "Node.js $(node --version)"

echo "npm $(npm --version)"

npm_dependencies=(
    "firebase-tools"
    "neovim"
    "typescript-language-server"
    "typescript"
)

npm_dependencies=($(comm -13 <(printf "%s\n" "${npm_dependencies[@]}" | sort) <(npm list -g --depth=0 --parseable | awk -F'/' '{print $NF}' | sort)))

if [ ${#npm_dependencies[@]} -gt 0 ]; then
    npm install -g "${npm_dependencies[@]}"
fi

unset nvm_version npm_dependencies
