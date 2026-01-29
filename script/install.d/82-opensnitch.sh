#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install OpenSnitch application firewall on Linux.
#   Docs: https://github.com/evilsocket/opensnitch/wiki/Installation
#

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command -v opensnitchd &>/dev/null || ! command -v opensnitch-ui &>/dev/null; then
        echo "Installing OpenSnitch..."
        
        # Create temporary directory for downloads
        temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        # Use a known stable version as fallback
        LATEST_VERSION="v1.7.0.0"
        
        # Try to get the latest release version, but don't fail if it doesn't work
        RELEASE_URL="https://api.github.com/repos/evilsocket/opensnitch/releases/latest"
        LATEST_FROM_API=$(curl -s "$RELEASE_URL" 2>/dev/null | grep '"tag_name"' | cut -d'"' -f4 2>/dev/null)
        
        if [[ -n "$LATEST_FROM_API" ]]; then
            LATEST_VERSION="$LATEST_FROM_API"
            echo "Using latest version: $LATEST_VERSION"
        else
            echo "Using fallback version: $LATEST_VERSION"
        fi
        
        # Download URLs for the .deb packages (note the -1 suffix in the filename)
        VERSION_NUM="${LATEST_VERSION#v}"
        DAEMON_URL="https://github.com/evilsocket/opensnitch/releases/download/${LATEST_VERSION}/opensnitch_${VERSION_NUM}-1_amd64.deb"
        UI_URL="https://github.com/evilsocket/opensnitch/releases/download/${LATEST_VERSION}/python3-opensnitch-ui_${VERSION_NUM}-1_all.deb"
        
        # Download the packages
        echo "Downloading OpenSnitch daemon from: $DAEMON_URL"
        if ! wget -q "$DAEMON_URL" -O "opensnitch.deb"; then
            echo "Failed to download OpenSnitch daemon"
            cd - >/dev/null
            rm -rf "$temp_dir"
            exit 1
        fi
        
        echo "Downloading OpenSnitch UI from: $UI_URL"
        if ! wget -q "$UI_URL" -O "opensnitch-ui.deb"; then
            echo "Failed to download OpenSnitch UI"
            cd - >/dev/null
            rm -rf "$temp_dir"
            exit 1
        fi
        
        # Install the packages
        echo "Installing OpenSnitch packages..." 
        sudo apt-get install -qq ./opensnitch.deb ./opensnitch-ui.deb
        
        # Clean up
        cd - >/dev/null
        rm -rf "$temp_dir"
        
        # Enable and start the service
        sudo systemctl enable opensnitch &>/dev/null || true
        sudo systemctl start opensnitch &>/dev/null || true
        
        echo "OpenSnitch installation completed"
    else
        echo "OpenSnitch is already installed"
    fi
    
    # Display version information
    if command -v opensnitchd &>/dev/null; then
        opensnitchd --version 2>/dev/null || echo "OpenSnitch daemon installed"
    fi
else
    echo -e "${YELLOW}Skipping OpenSnitch: Linux only${NC}"
fi