# andrejusk/dotfiles

[![Dotfiles CI status badge](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml)

A collection of dotfiles and install scripts
to set up my development environment
🛠️ 📂️ 🚀

## Usage

A local repository can be installed and updated by running:

    ./install

A specific script can be installed by running:

    ./install script1 script2 ...

### Automated setup

This repository can be installed without a local copy
by invoking the `setup-new` script directly via `curl`:

    # Inspect source
    curl -s https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup-new | less

    # Run
    curl -s https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup-new | bash

## Keyboard shortcuts

| Key | Mnemonic | Action |
|-----|----------|--------|
| `^A` | **A**ll commits | Git log browser with diff preview |
| `^B` | **B**ranch | Git branch checkout with log preview |
| `^E` | **E**dit | Find and edit file in `$EDITOR` |
| `^F` | **F**ind | Find in files (rg + fzf), open at line |
| `^G` | **G**o remote | SSH/codespace connect *(local only)* |
| `^J` | **J**ump | Zoxide directory jump |
| `^K` | **K**ommands | Command help lookup (tldr/man) |
| `^N` | **N**avigate | Tmux session create/attach |
| `^O` | **O**pen | Open repo/PR/issues/actions in browser |
| `^P` | **P**roject | Switch to workspace project |
| `^R` | **R**everse | Fuzzy search command history *(fzf built-in)* |
| `^S` | **S**ession | Browse & resume Copilot CLI sessions |
| `^X` | e**X**ecute | Process manager (fzf + kill) |
| `^Y` | **Y**ank stash | Browse git stashes with diff preview |

