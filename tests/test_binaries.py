#!/usr/bin/env python3

from distutils.spawn import find_executable
from typing import List, Text
import pytest

#
# Verify expected dots binaries are available
#


# List of expected shells
shells: List[Text] = [
    "bash",
    "fish",
    "sh",
]

# List of expected binaries
binaries: List[Text] = [
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


# --------------------------------------------------------------------------- #
# Tests
# --------------------------------------------------------------------------- #
@pytest.mark.parametrize("shell", shells)
def test_shells(shell: Text):
    """Assert all expected shells are in PATH."""

    assert find_executable(shell) is not None


@pytest.mark.parametrize("binary", binaries)
def test_binaries(binary: Text):
    """Asserts all expected binaries are in PATH."""

    assert find_executable(binary) is not None
