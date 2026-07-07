---
name: local-dev-container
description: >-
  Run a repository's dev container locally in a Linux VM using the
  `dev-container` helper, for fast, isolated, disposable development. Use when
  the user wants to work on a repo "in a container", spin up an isolated or
  throwaway dev environment, run several feature branches in parallel, offload
  autonomous coding to containerized agents, or when host file operations
  (search / build / test) are slow because an endpoint security agent scans
  every file the host opens. Not for running a full multi-service app stack
  (see "Limits" below).
---

# Local development containers

`dev-container` runs a repository's own `devcontainer.json` locally inside a
Linux VM (via podman), with the working tree in a **named volume** rather than a
host bind mount. This matters for speed: some managed machines run an endpoint
security agent that scans every file `open()` on the host filesystem, so
searching/building a large repo on the host is very slow. File I/O **inside the
VM never touches the host filesystem**, so it is not scanned — search, install,
and test run at native speed.

Prerequisites (installed by the dotfiles on macOS/Apple Silicon): `podman`, the
`@devcontainers/cli`, and an authenticated `gh`. The podman VM starts
automatically on first use. If `dev-container` is not on PATH, the toolchain is
not installed on this machine — fall back to working on the host.

## Mental model — what persists

- **Container = disposable.** It runs until stopped, removed, or the VM stops
  (reboot/sleep). Recreating it is fast.
- **Named volumes = persistent.** The cloned working tree and the in-container
  `~/.copilot` session data survive teardown and reboots.
- **Built image = cached.** Re-running skips the rebuild.

So you never lose work by removing a container; re-running `dev-container` on the
same repo/instance reattaches to the same persistent volumes.

## Commands

```sh
dev-container <owner>/<repo>              # clone into a volume, build, open copilot inside
dev-container <owner>/<repo> --shell      # open a shell instead of copilot
dev-container <owner>/<repo> --up-only    # bring it up, don't attach
dev-container <owner>/<repo> --branch B   # clone a specific branch (first time only)
dev-container <owner>/<repo> --skip-setup # skip lifecycle scripts (use when the
                                          # repo's bootstrap needs a VPN/network
                                          # it can't reach; still gives the repo
                                          # + toolchain for code work)
dev-container --status                    # list instances (container / state / repo / instance)
dev-container --rm <owner>/<repo> [name]  # remove a container + its volumes
```

## Working on several branches at once

Each `--name` is a fully independent instance (its own clone, `~/.copilot`
volume, and container), so branches don't interfere:

```sh
dev-container <owner>/<repo> --name feat-a --branch feat-a --copilot
dev-container <owner>/<repo> --name feat-b --branch feat-b --copilot
```

## Orchestrating containerized agents (headless)

The Copilot CLI has a non-interactive mode (`copilot -p "<prompt>" --allow-all`).
Combined with `--exec`, an outer/host Copilot session can drive autonomous work
**inside** a container without a human attaching:

```sh
# Run one autonomous task in a container and capture its output:
dev-container <owner>/<repo> --skip-setup \
  --exec 'copilot -p "implement <task> and run the tests" --allow-all'

# Fan out parallel tasks across isolated instances (a simple agent fleet):
dev-container <owner>/<repo> --name task-1 --skip-setup \
  --exec 'copilot -p "<task 1>" --allow-all' &
dev-container <owner>/<repo> --name task-2 --skip-setup \
  --exec 'copilot -p "<task 2>" --allow-all' &
wait
```

Guidance for an orchestrating agent:
- For **autonomous** work, use `--exec 'copilot -p "..." --allow-all'` — never
  try to drive the interactive TUI, it will block.
- To **hand off to a human**, run `--up-only`, then tell the user the exact
  `dev-container <repo> [--name ...] --copilot` command to enter.
- Give each parallel task its own `--name` so their working trees and sessions
  stay isolated.
- Inspect progress with `dev-container --status`; clean up with `--rm`.

## Limits — when to use the remote environment instead

`dev-container` is for **code work**: editing, searching, linting, type-checking,
and unit tests. It is not wired to run a full multi-service application stack
(databases, search, message queues, and other backing services), which needs
those services bootstrapped, the right network access, and often several
sibling repositories mounted together. For running the actual application or
integration testing against real services, use the project's remote/cloud
development environment. Locally, `dev-container` deliberately does not publish
the repo's forwarded ports (it runs headless for code work).
