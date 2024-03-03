# andrejusk/dotfiles

[![Dotfiles CI status badge](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml)

My collection of dotfiles and install scripts
to set up development environments
🛠️ 📂️ 🚀

## Usage

A local repository can be installed by running:

    ./script/install

<details>
<summary>
Environment configuration for <code>install</code> script
</summary>

| Variable | Description |
| --- | --- |
| `LOG_TARGET` | File to log installation output to (default: `~/.dotfiles/logs/install-{date}.log`) |
</details>

### Automated setup

This repository can be installed without a local copy
by invoking the `setup` script directly via `curl`:

    # Inspect source
    curl -s https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup | less

    # Run
    curl -s https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup | bash


<details>
<summary>
Environment configuration for <code>setup</code> script
</summary>

| Variable | Description |
| --- | --- |
| `DOTFILES_DIR` | Directory to clone the repository into (default: `~/.dotfiles`)
| `DOTFILES_SKIP_INSTALL` | Skip running the install script (default: `false`)
| `GITHUB_AUTHOR` | GitHub username to use for cloning repositories (default: `andrejusk`) |
| `GITHUB_REPO` | GitHub repository name to clone (default: `dotfiles`)
| `GITHUB_BRANCH` | GitHub branch to clone (default: `master`)
</details>
