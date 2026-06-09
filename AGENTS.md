# Agent instructions

Guidance for AI agents working in this repository. This file is the single
source of truth for conventions; it supersedes any external context.

## Priorities

Optimise for these, in order, and call out conflicts explicitly:

1. **Shell performance** — Target <200ms startup, <0.1ms prompt render. Prefer
   lazy loading, caching, and async patterns. Avoid subshells in hot paths
   (`precmd`/`preexec`, prompt rendering). Profile with `ZSH_BENCH=1 zsh`.
2. **Cross-platform portability** — Support macOS, Debian, Arch, Fedora, Alpine
   (incl. iSH) and GitHub Codespaces. Respect the split between persistent local
   environments and ephemeral cloud workspaces.
3. **Minimal dependencies** — Use GNU Stow for symlink management and `mise` for
   developer tools. Prefer native package managers. Avoid tools that duplicate
   existing functionality.
4. **Accessibility** — Ensure colour-blind-safe output. Degrade gracefully when
   Nerd Fonts are unavailable (every symbol needs an ASCII fallback).
5. **Idempotency** — Every script must be safe to re-run with no side effects.

When proposing changes, benchmark startup impact where relevant, consider all
target platforms (not just the current one), and check the ADRs below.

## Architecture decisions (ADRs)

Respect these. If a change conflicts with one, flag the conflict rather than
silently breaking it.

- **Retain GNU Stow** — chezmoi adds complexity without solving a current problem.
- **`_dots_` prefix on all custom functions** — namespace separation, avoids
  plugin clashes.
- **`typeset -g` for globals** — explicit scoping prevents accidental shadowing.
- **`[[ ]]` over `[ ]`** — Zsh-native, faster, fewer edge cases.
- **`(( ))` for arithmetic** — avoids word-splitting issues.
- **Cache computed values** — reduce redundant work in hot functions; bust caches
  on tool/binary mtime change.
- **Require Zsh 5.8+** — minimum for async and prompt performance.
- **Async git status** — prompt responsiveness beats immediate git accuracy;
  update in the background. Use fswatch/inotify events, not polling.
- **Avoid subshells in `precmd`/`preexec`** — subshell overhead breaks the
  <0.1ms render target.
- **Lazy-load language runtimes** — defer runtime/tool init until first use to
  protect startup time.
- **Two-line prompt** — info on line 1, input on line 2.
- **Abbreviated path keeps the last 3 components full** — context vs. width.
- **Nerd Fonts are optional** — git/status symbols must degrade to ASCII.
- **Colour-blind-accessible palette** — never rely on red/green alone; always
  pair with a symbol. Tested with the Coblis simulator.
- **Defer to platform-managed runtimes in ephemeral environments** — do not
  override pre-provisioned toolchains (e.g. Codespaces runtimes).
- **Prefer native package managers** — Homebrew on macOS, APT on
  Debian/Codespaces, Pacman on Arch, APK on Alpine; do not cross-pollinate
  package ecosystems.

## Environment contract

`script/install` exports these for all `install.d/` scripts; reuse them rather
than re-detecting:

- `DOTS_OS` — `macos` | `linux`.
- `DOTS_PKG` — `brew` | `apt` | `pacman` | `apk` | `dnf`.
- `DOTS_ENV` — `codespaces` when applicable (otherwise empty).
- `DOTS_THEME` — `dark` | `light`; resolved as explicit > `COLORFGBG` > macOS
  appearance > dark. Drives `BAT_THEME`, `GLAMOUR_STYLE`, `DELTA_FEATURES`, and
  the prompt/`LS_COLORS` palettes.

Guard platform-specific work with these (plus `uname -m` for Apple-Silicon-only
tools), returning early via `log_skip` when not applicable.

## Tooling

- **Manage developer tools through `mise`**, not ad-hoc package managers (see
  `install.d/30-mise.sh`). Prefer a `mise` backend (`core`, `aqua`, `cargo:`,
  `ubi:`, `pipx:`, etc.) over a direct `brew install`, `pip install`,
  `uv tool install`, or `cargo install`.
- **Prefer version-locked `mise` installs** when a pinned version is available
  (e.g. `mise use -g "gh@2.86.0"`). Reserve `@latest` for tools where pinning is
  impractical, matching the existing split in `install.d/30-mise.sh`.
- In Codespaces, skip runtime installs and defer to pre-provisioned versions.

## Install scripts

- Scripts live in `install.d/`, run in filename order (`NN-name.sh`), and are
  `source`d by `script/install`. Reuse the log helpers (`log_info`, `log_pass`,
  `log_skip`, `log_warn`, `log_error`, `log_quote`, `log_indent`).
- Keep scripts idempotent: check before installing, make re-runs a no-op.
- Run a single target with `./install <name>` (e.g. `./install mise`).

## Build & test

- CI (`.github/workflows/ci.yml`) builds a Docker matrix —
  `Dockerfile` (Debian), `Dockerfile.arch`, `Dockerfile.alpine` — and runs the
  test suite in each.
- `./script/test` builds the image (`--target test`) and runs `tests/`.
- `tests/test_binaries.py` (pytest) asserts expected binaries resolve in `sh`,
  `bash`, and `zsh`. Add new tools there when introducing them.
- Profile shell startup with `ZSH_BENCH=1 zsh` (loads `zsh/zprof`).

## Colours

Palette is chosen for accessibility and cross-terminal
compatibility. Core semantic mappings (full reference: `docs/COLOURS.md`):

| Usage | Name | Hex |
|---|---|---|
| Errors / critical | Red | `#F40404` |
| Information / links | Blue | `#0C48CC` |
| Success / active | Teal | `#2CB494` |
| Warnings | Yellow | `#FCFC38` |
| Pending / in-progress | Orange | `#F88C14` |
| Special / features | Purple | `#88409C` |
| Default text | White | `#CCE0D0` |
| Disabled / comments | Grey | `#808080` |

- Colour-blind-safe pairings: Teal/Orange, Blue/Yellow, Purple/Cyan.
- Never use red/green as the sole signal — pair with `✓`/`✗` (ASCII `+`/`x`).
- Map to the ANSI 256 palette where true colour is unavailable.
