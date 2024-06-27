#!/usr/bin/env python3
#
# Verifies dotfiles installed binaries correctly
#
from distutils.spawn import find_executable
from typing import List, Text
from subprocess import run
import pytest
import os


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
    Check whether `binary` is in interactive shell's PATH
    """
    command = f"{shell} -c 'command -v {binary}'"
    try:
        result = run(command, shell=True)
        return result.returncode == 0
    except Exception:
        return False


# --------------------------------------------------------------------------- #
# Test fixtures
# --------------------------------------------------------------------------- #
shells: List[Text] = [
    "sh",
    "bash",
    "zsh",
]

binaries: List[Text] = [
    # extend shells
    *shells,
    # tools
    "git",
    "gh",
    "terraform",
    "docker" if not os.environ.get("SKIP_DOCKER_CONFIG") else None,
    "neofetch",
    "redis-cli",
    "redis-server",
    # language: python
    "pyenv",
    "python",
    "python3",
    "pip",
    "pip3",
    "pipx",
    "poetry",
    # langauge: js
    "node",
    "npm",
    "yarn",
]
binaries = [binary for binary in binaries if binary is not None]


# --------------------------------------------------------------------------- #
# Tests
# --------------------------------------------------------------------------- #
@pytest.mark.parametrize("shell", shells)
def test_shells(shell: Text):
    """Assert all expected shells are in PATH."""
    assert in_path(shell)


@pytest.mark.parametrize("binary", binaries)
@pytest.mark.parametrize("shell", shells)
def test_binaries(shell: Text, binary: Text):
    """Asserts all expected binaries are in all shells."""
    assert in_shell_path(shell, binary)
