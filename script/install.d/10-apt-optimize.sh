#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (distros with apt only) Optimize apt and run update once for all scripts.
#

# apt only
[[ "$DOTS_PKG" != "apt" ]] && { log_warn "Skipping: Not using apt"; return 0; }

log_info "Optimizing apt configuration..."

# Create apt optimization config
sudo tee /etc/apt/apt.conf.d/99codespace-optimizations >/dev/null <<'EOF'
APT::Install-Recommends "0";
APT::Install-Suggests "0";
Acquire::Languages "none";
Acquire::http::Pipeline-Depth "5";
EOF

log_info "Running apt update (once for all scripts)..."
sudo apt-get update -qq

# Mark that update is done so other scripts can skip
export APT_UPDATED=1

log_pass "apt optimized and updated"
