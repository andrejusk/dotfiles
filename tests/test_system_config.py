#!/usr/bin/env python3
#
# Test system configuration for ENOSPC fix
#
import subprocess
import pytest
import os


def test_inotify_limit_sufficient():
    """Test that inotify limit is set to prevent ENOSPC errors."""
    if os.name != 'posix':
        pytest.skip("inotify configuration only applies to Linux systems")
    
    try:
        with open('/proc/sys/fs/inotify/max_user_watches', 'r') as f:
            current_limit = int(f.read().strip())
    except (FileNotFoundError, ValueError):
        pytest.skip("inotify configuration not available on this system")
    
    # The minimum recommended limit to prevent ENOSPC errors
    min_recommended_limit = 524288
    
    assert current_limit >= min_recommended_limit, \
        f"inotify limit ({current_limit}) is below recommended minimum ({min_recommended_limit}) to prevent ENOSPC"


def test_system_script_exists():
    """Test that the system configuration script exists and is executable."""
    script_path = "/home/runner/work/dotfiles/dotfiles/script/install.d/01a-system.sh"
    
    assert os.path.exists(script_path), "System configuration script does not exist"
    assert os.access(script_path, os.X_OK), "System configuration script is not executable"


def test_system_script_runs_without_error():
    """Test that the system configuration script runs without errors."""
    script_path = "/home/runner/work/dotfiles/dotfiles/script/install.d/01a-system.sh"
    
    # Set environment to skip color codes for clean output
    env = os.environ.copy()
    env['TERM'] = 'dumb'
    
    try:
        result = subprocess.run(
            ['bash', script_path],
            capture_output=True,
            text=True,
            timeout=30,
            env=env
        )
        
        assert result.returncode == 0, \
            f"System script failed with return code {result.returncode}. stderr: {result.stderr}"
            
    except subprocess.TimeoutExpired:
        pytest.fail("System script timed out")