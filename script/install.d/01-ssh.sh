#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Print SSH key.
#

# skip if CODESPACES is set
if [ -n "$CODESPACES" ]; then
    echo -e "${YELLOW}Running in a GitHub Codespace${NC}"
    export SKIP_SSH_CONFIG=1
fi

# skip if SKIP_SSH_CONFIG is set
if [ -z "$SKIP_SSH_CONFIG" ]; then
    ssh_method="ed25519"

    ssh_target="${HOME}/.ssh"
    ssh_key="${ssh_target}/id_${ssh_method}"
    ssh_pub="${ssh_key}.pub"
    if [ ! -f $ssh_key ]; then
        ssh-keygen \
            -t $ssh_method \
            -f $ssh_key \
            -C "$(whoami)@$(hostname)-$(date -I)"
    fi

    cat $ssh_pub

    unset ssh_method ssh_target ssh_key ssh_pub
else
    echo -e "${YELLOW}Skipping SSH configuration${NC}"
fi
