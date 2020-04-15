#!/usr/bin/env python3
#
# Verifies dotfiles installed binaries correctly
#
from distutils.spawn import find_executable
from typing import List
from subprocess import run, CalledProcessError
import pytest


# ---------------------------------------------------------------------------- #
#	Helper functions
# ---------------------------------------------------------------------------- #
def in_path(binary: str) -> bool:
    """
    Helper function to check whether `binary` is in PATH.
    """
    return find_executable(binary) is not None

def in_shell_path(shell: str, binary: str) -> bool:
    """
    Helper function to check whether `binary` is in interactive shell's PATH.
    """
    command = "{0} -i -c 'command -v {1}'".format(shell, binary)
    try:
        result = run(command, shell=True)
        return (result.returncode == 0)
    except:
        return False


# ---------------------------------------------------------------------------- #
#	Test fixtures
# ---------------------------------------------------------------------------- #
shells: List[str] = [
    'sh', 'bash', 'fish',
]

binaries: List[str] = [

    # extend shells
    *shells,

    # tools
    "git",
    "keybase", "firebase", "aws", "terraform",
    "docker", "docker-compose",
    "screenfetch",

    # language: python
    "pyenv", "python3", "pip3", "poetry",

    # langauge: node
    "nvm", "node", "npm", "yarn",
    
]


# ---------------------------------------------------------------------------- #
#	Tests
# ---------------------------------------------------------------------------- #
@pytest.mark.parametrize("shell", shells)
def test_shells(shell: str):
    """ Assert all shells we expect are in PATH. """
    assert in_path(shell)

@pytest.mark.parametrize("binary", binaries)
@pytest.mark.parametrize("shell", shells)
def test_binaries(shell: str, binary: str):
    """ Asserts all binaries are in all shells. """
    assert in_shell_path(shell, binary)
