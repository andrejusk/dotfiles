#!/usr/bin/env python3

from distutils.spawn import find_executable
import os
import pytest
import typing as t


# --------------------------------------------------------------------------- #
# Fixtures to verify expected binaries are available in local environment
# --------------------------------------------------------------------------- #

# List of expected shells
shells: t.List[t.Text] = [
    "bash",
    "fish",
    "sh",
]

# List of expected binaries
binaries: t.List[t.Text] = [
    #
    # tools
    #
    "batcat",
    "exa",
    "fd",
    "fzf",
    "lorri",
    "niv",
    "nix",
    "rg",
    "tokei",
    #
    # editors
    #
    "emacs",
    "nvim",
    #
    # tools: cloud
    #
    "aws",
    "firebase",
    "gcloud",
    #
    # tools: devops
    #
    "docker-compose",
    "docker",
    "gh",
    "git",
    "kubectl",
    "terraform",
    "terraspace",
    #
    # language: python
    #
    "pip",
    "pip3",
    "poetry",
    "pyenv",
    "python",
    "python3",
    #
    # langauge: js
    #
    "node",
    "npm",
    "yarn",
    #
    # language: java
    #
    "java",
    #
    # gags
    #
    "cowsay",
    "cmatrix",
    "figlet",
    "fortune",
    "screenfetch",
]

# List of expected directories
dirs: t.List[t.Text] = [
    "/.poetry/bin",
    "/.nix-profile/bin",
    "/.pyenv/shims",
    "/.pyenv/bin",
    "/.yarn/bin",
    "/.local/bin",
]


# --------------------------------------------------------------------------- #
# Tests
# --------------------------------------------------------------------------- #
@pytest.mark.parametrize("shell", shells)
def test_shells(shell: t.Text):
    """
    Assert expected shell is in PATH

    Args:
        shell: shell to test
    """

    assert find_executable(shell) is not None


@pytest.mark.parametrize("binary", binaries)
def test_binaries(binary: t.Text):
    """
    Assert expected binary is in PATH

    Args:
        binary: binary to test
    """

    assert find_executable(binary) is not None

@pytest.mark.parametrize("directory", dirs)
def test_dirs(directory: t.Text):
    """
    Assert expected directory is in PATH

    Args:
        directory: directory to test
    """

    assert directory in os.environ["PATH"]
