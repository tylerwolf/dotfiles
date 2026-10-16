# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A topic-based dotfiles repository for macOS and Linux (Arch/CachyOS and Debian/Ubuntu), inspired by Holman's dotfiles. Each tool/concern gets its own directory with conventionally-named files that are automatically discovered and loaded. Each platform uses its native package manager; files can be tagged for a platform by name.

## Key Commands

Three layers, each with one job:

- `script/bootstrap` — From nothing: install git (and Command Line Tools on macOS), clone to `~/.dotfiles`, run `dotfiles install`, offer `dotfiles ssh-key`. This is the one-liner in the README; re-runnable on an existing clone. Env: `DOTFILES_DIR`, `DOTFILES_REPO`, `DOTFILES_BRANCH`.
- `bin/dotfiles` — The user command (on `$PATH` via `$DOTFILES/bin`):
  - `dotfiles install` — Symlinks, dangling-link cleanup, package topics first, then all topic installers, then offer zsh as login shell. Idempotent.
  - `dotfiles update` — Pull (https `updates` remote), submodules, `install`, `mise upgrade`. Run by launchd / systemd.
  - `dotfiles verify` — Platform-aware checks.
  - `dotfiles defaults` — `macos/set-defaults.sh`.
  - `dotfiles ssh-key` — Generate `~/.ssh/id_ed25519` if missing, register with GitHub via `gh`, switch `origin` to ssh.
- `topic/install.sh` — Per-topic setup, run by `dotfiles install`.

- `make lint` — Run shellcheck on all shell scripts (`.sh` files, `script/*`, `bin/*`)
- `make verify` — `dotfiles verify`
- `make macos-setup` — One-time: install Tart, pull macOS Tahoe base image
- `make macos-test` — Automated: clone fresh macOS VM, run `script/bootstrap`, verify, cleanup
- `make macos-shell` — Interactive: clone fresh macOS VM, print SSH command for manual exploration
- `make macos-ready` — Pre-bootstrapped: clone fresh macOS VM, run bootstrap + defaults, print SSH command
- `make macos-cleanup` — Stop and delete all leftover `dotfiles-test-*` VMs
- `make linux-test` — Automated: `script/bootstrap` + verify in CachyOS and Ubuntu 24.04 Docker containers (`make arch-test`, `make ubuntu-test` individually)
- `make arch-shell` / `make ubuntu-shell` — Interactive: bootstrap a container, open zsh

## Architecture

### Platform Detection

`script/os.sh` is sourced by `bin/dotfiles` and every topic installer (`script/bootstrap` inlines the same checks since it runs before the clone exists). It exports:

- `DOTFILES_OS` — `darwin` | `linux`
- `DOTFILES_DISTRO` — `arch` | `debian` | empty
- `DOTFILES_TAGS` — e.g. `darwin`, `linux arch`, `linux debian`

It also puts Homebrew (macOS) and `~/.local/bin` on PATH. `zsh/zshrc.symlink` recomputes the same tags without forking.

### File Convention System

The zsh loader (`zsh/zshrc.symlink`) auto-discovers files by naming convention across all topic directories, skipping files tagged for another platform (`foo.darwin.zsh`, `foo.linux.zsh`, `foo.arch.zsh`, `foo.debian.zsh`):

1. **`path.zsh`** (and `path.<tag>.zsh`) — Loaded first. Use for `$PATH` modifications.
2. **`*.zsh`** (except path/completion) — Loaded second. Config, aliases, etc.
3. **`completion.zsh`** — Loaded last. Shell completions.
4. **`install.sh`** / **`install.<tag>.sh`** — Per-topic installer, run by `dotfiles install`. Package-manager topics (`homebrew`, `pacman`, `apt`, `mise`) run before the rest. Discovery uses `git ls-tree`, so new installers must be committed (or overlaid, as the test scripts do).
5. **`*.symlink`** / **`*.<tag>.symlink`** — Symlinked to `$HOME/.filename` (stripping `.symlink` and the tag) by `dotfiles install`. Dangling links into the repo are removed.

### Packages

One list per package manager; keep them in sync (headers cross-reference each other):

- `homebrew/Brewfile.darwin.symlink` — macOS
- `pacman/packages.txt` + `pacman/aur.txt` — Arch (AUR via `yay`, falling back to `paru`)
- `apt/packages.txt` — Debian/Ubuntu base packages
- `mise/cli-tools.debian.toml` — modern CLI tools on Debian/Ubuntu (apt ships them stale/missing), installed by mise under canonical binary names

`mise/global.toml` holds global runtime versions (node); it replaced asdf and direnv. Antidote is git-cloned to `~/.antidote` on every platform.

GUI apps: Ghostty is the terminal on macOS (`cask 'ghostty'`) and Arch (`ghostty`); `ghostty/config` is one shared file linked to `~/.config/ghostty/config`. Topics that manage files under `~/.config` link them from their `install.sh` using `link_config` from `script/link.sh` (the `*.symlink` convention only covers `~/.name`).

### Auto-Update

`autoupdate/` installs a launchd agent on macOS (`install.darwin.sh`) or a systemd user timer `dotfiles-update.timer` on Linux (`install.linux.sh`, with `loginctl enable-linger` for headless hosts). Both run `dotfiles update` every 2 hours. Package installers skip sudo-requiring steps when there is no tty.

### Environment Variables

- `$DOTFILES` → `$HOME/.dotfiles` (repo location)
- `$PROJECTS` → `$HOME/Code`
- `$EDITOR` → `vim`

### Local Customization (not versioned)

- `~/.localrc` — Sourced at the end of zshrc only (zsh syntax allowed; `dotfiles update` does not read it)
- `~/.gitconfig.local` — Included by gitconfig
- `~/.config/mise/config.local.toml` — Machine-specific mise tools

### Testing

- macOS: `script/test-macos` (Tart VMs) overlays the working tree into `~/.dotfiles`, runs `script/bootstrap`, `macos/set-defaults.sh`, `dotfiles verify` over SSH
- Linux: `script/test-linux` builds `script/docker/{arch,ubuntu}.Dockerfile` (x86-64, Rosetta on Apple Silicon), overlays the working tree into `~/.dotfiles`, runs `script/bootstrap` + `dotfiles verify` + `zsh -ic`. Containers lack systemd, so timer state is only checked on the Ubuntu CI runner.
- CI (`.github/workflows/ci.yml`): lint, bootstrap-macos, bootstrap-arch (CachyOS container), bootstrap-ubuntu (native 24.04 runner). Dependabot (`.github/dependabot.yml`) bumps action tags and the Docker base images monthly; tool versions are mise's job.

### Repository Assets

- `.github/logo.png` — README header logo (referenced in README.md)

## Adding a New Topic

1. Create a directory named after the tool (e.g., `node/`)
2. Add `path.zsh` if PATH changes are needed
3. Add `config.zsh` or `aliases.zsh` for shell configuration
4. Add `install.sh` for one-time setup; source `script/os.sh` for platform variables
5. Add `*.symlink` files for dotfiles that should land in `$HOME`
6. Tag platform-specific files (`.darwin`, `.linux`, `.arch`, `.debian`) before the extension
7. Add the package to every platform's package list

Existing files are backed up with `.backup` suffix during symlink creation.

## Workflow Rules

- **Use Make targets** when they exist (e.g., `make lint` not `shellcheck ...` directly)
- **Lint and test before committing** — run `make lint`, `make macos-test` and `make linux-test` before every commit
- **Update CLAUDE.md** whenever new commands are added or architecture materially changes
- **Update README.md** whenever changes affect documented features, commands, or structure
