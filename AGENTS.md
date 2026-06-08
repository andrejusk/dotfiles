# Agent instructions

Guidance for AI agents working in this repository.

## Tooling

- **Manage developer tools through `mise`**, not ad-hoc package managers. This is
  the repository convention (see `install.d/30-mise.sh`). Prefer a `mise` backend
  (`core`, `aqua`, `cargo:`, `ubi:`, `pipx:`, etc.) over a direct `brew install`,
  `pip install`, `uv tool install`, or `cargo install`.
- **Always prefer version-locked `mise` installs when a pinned version is
  available.** Pin to an explicit version (e.g. `mise use -g "gh@2.86.0"`,
  `mise use -g "pipx:mlx-lm@0.31.3"`) rather than `@latest`. Reserve `@latest`
  for tools where pinning is impractical, matching the existing split in
  `install.d/30-mise.sh`.

## Install scripts

- Install scripts live in `install.d/`, run in filename order (`NN-name.sh`), and
  are `source`d by `script/install`. Reuse the provided log helpers
  (`log_info`, `log_pass`, `log_skip`, `log_warn`, `log_error`, `log_quote`).
- Guard platform-specific scripts with the exported `DOTS_OS`, `DOTS_PKG`, and
  `DOTS_ENV` variables (and `uname -m` for Apple-Silicon-only tools), returning
  early via `log_skip` when not applicable.
- Keep scripts idempotent: check before installing and make re-runs a no-op.
