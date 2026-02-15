#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure system limits and parameters.
#

# Fix ENOSPC (Error No Space) issue for Node.js file watching
# This commonly occurs when development tools exceed inotify limits
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    current_limit=$(cat /proc/sys/fs/inotify/max_user_watches 2>/dev/null || echo "0")
    recommended_limit=524288
    
    if [ "$current_limit" -lt "$recommended_limit" ]; then
        echo "Current inotify limit: $current_limit"
        echo "Setting inotify limit to: $recommended_limit"
        
        # Add to sysctl configuration if not already present
        sysctl_config="/etc/sysctl.d/99-dotfiles.conf"
        if ! grep -q "fs.inotify.max_user_watches" "$sysctl_config" 2>/dev/null; then
            echo "fs.inotify.max_user_watches=$recommended_limit" | sudo tee -a "$sysctl_config" > /dev/null
            echo "Added inotify configuration to $sysctl_config"
        fi
        
        # Apply the setting immediately
        echo "$recommended_limit" | sudo tee /proc/sys/fs/inotify/max_user_watches > /dev/null
        
        # Verify the change
        new_limit=$(cat /proc/sys/fs/inotify/max_user_watches 2>/dev/null || echo "0")
        echo "New inotify limit: $new_limit"
    else
        echo "inotify limit already sufficient: $current_limit"
    fi
else
    echo -e "${YELLOW}Skipping: inotify configuration not needed on $OSTYPE${NC}"
fi