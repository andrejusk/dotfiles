#!/usr/bin/env python3

from distutils.spawn import find_executable
from typing import List, Text
from subprocess import run
import pytest

#
# Verifies expected dots binaries are available
#

# --------------------------------------------------------------------------- #
# Helper functions
# --------------------------------------------------------------------------- #
def in_path(binary: Text) -> bool:
    """
    Check whether `binary` is in PATH
    """
    return find_executable(binary) is not None


def in_shell_path(shell: Text, binary: Text) -> bool:
    """
    Check whether `binary` is in interactive login shell's PATH
    """
    # FIXME
    command = f"{shell} -i -l -c \"command -v {binary}\""
    try:
        result = run(command, shell=True)
        return result.returncode == 0
    except Exception:
        return False


# --------------------------------------------------------------------------- #
# Test fixtures
# --------------------------------------------------------------------------- #
shells: List[Text] = [
    "bash",
    "fish",
    "sh",
]

binaries: List[Text] = [
    # extend shells
    *shells,
    # tools
    "aws",
    "docker-compose",
    "docker",
    "emacs",
    "firebase",
    "fzf",
    "gcloud",
    "gh",
    "git",
    "kubectl",
    "nix",
    "nvim",
    "rg",
    "terraform",
    # gags
    "cowsay",
    "cmatrix",
    "figlet",
    "fortune",
    "screenfetch",
    # language: python
    "pip",
    "pip3",
    "poetry",
    "pyenv",
    "python",
    "python3",
    # langauge: js
    "node",
    "npm",
    "yarn",
    # language: java
    "java",
]


# --------------------------------------------------------------------------- #
# Tests
# --------------------------------------------------------------------------- #
@pytest.mark.parametrize("shell", shells)
def test_shells(shell: Text):
    """Assert all expected shells are in PATH."""
    assert in_path(shell)


@pytest.mark.parametrize("binary", binaries)
# @pytest.mark.parametrize("shell", shells)
def test_binaries(binary: Text):
    """Asserts all expected binaries are in PATH."""
    # assert in_shell_path(shell, binary)
    assert in_path(binary)
