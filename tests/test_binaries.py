#!/usr/bin/env python3
#
# Verifies dotfiles install
#
from distutils.spawn import find_executable
from typing import List
import pytest


# List of binaries to test
binaries: List[str] = [

    # shells
    "sh", "bash", "fish",

    # tools
    "git",
    "keybase",
    "docker", "docker-compose",
    "screenfetch",

    # languages
    "pyenv",
    "python3",
    "poetry",
    
]


def binary_in_path(binary: str) -> bool:
    """ 
    Helper function to check whether `binary` is in PATH.    
    """

    return find_executable(binary) is not None


@pytest.mark.parametrize("binary", binaries)
def test_binaries(binary: str):
    """
    Asserts all binaries are in PATH.
    """
    assert binary_in_path(binary)
