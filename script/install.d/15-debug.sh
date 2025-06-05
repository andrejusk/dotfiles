#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install debugging tools.
#

# Install GDB for C++ debugging
if ! command -v gdb &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -qq gdb
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install gdb
    fi
fi

if command -v gdb &>/dev/null; then
    gdb --version | head -n 1
else
    echo -e "${YELLOW}GDB not available${NC}"
fi

# Note: PDB (Python debugger) is built into Python and doesn't require separate installation
if command -v python3 &>/dev/null; then
    python3 -c "import pdb; print('PDB (Python debugger) is available as built-in module')"
else
    echo -e "${YELLOW}Python not available for PDB${NC}"
fi