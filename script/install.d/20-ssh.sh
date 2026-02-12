#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Print SSH key.
#

# Skip in Codespaces (managed by GitHub)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_skip "Codespaces"; return 0; }

# Skip if explicitly disabled
[[ -n "$SKIP_SSH_CONFIG" ]] && { log_skip "SKIP_SSH_CONFIG is set"; return 0; }

ssh_method="ed25519"

ssh_target="${HOME}/.ssh"
ssh_key="${ssh_target}/id_${ssh_method}"
ssh_pub="${ssh_key}.pub"
if [ ! -f "$ssh_key" ]; then
    ssh-keygen \
        -t "$ssh_method" \
        -f "$ssh_key" \
        -C "$(whoami)@$(hostname)-$(date -I)"
fi

cat "$ssh_pub"

unset ssh_method ssh_target ssh_key ssh_pub
log_pass "SSH key configured"
