<p align="center">
  <img src=".github/logo.png" alt="Tyler Wolf dotfiles" width="600">
</p>

<p align="center">
  <a href="https://github.com/tylerwolf/dotfiles/actions/workflows/ci.yml"><img src="https://github.com/tylerwolf/dotfiles/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/macOS-Tahoe-000000?logo=apple&logoColor=white" alt="macOS Tahoe">
  <img src="https://img.shields.io/badge/CachyOS-Arch-1793D1?logo=archlinux&logoColor=white" alt="CachyOS">
  <img src="https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white" alt="Ubuntu 24.04">
</p>

<p align="center">
  Topic-based dotfiles for macOS and Linux — organized, tested, and auto-updating.
</p>

---

## Install

On a new machine, run the one-liner:

```console
sh -c "$(curl -fsSL https://raw.githubusercontent.com/tylerwolf/dotfiles/main/script/bootstrap)"
```

`script/bootstrap` installs the bare prerequisites (git, and the Command Line Tools on macOS), clones this repo to `~/.dotfiles`, runs `dotfiles install`, and offers to create and register an SSH key for the machine with GitHub. Re-running it on an existing clone is safe.

Or by hand:

```console
git clone https://github.com/tylerwolf/dotfiles.git ~/.dotfiles
~/.dotfiles/bin/dotfiles install
```

### The `dotfiles` command

Everything after the clone is one command, on your `$PATH` once installed:

| Command | What it does |
|---------|-------------|
| `dotfiles install` | Make this machine match the repo: symlink `*.symlink` files into `$HOME`, remove dangling links, install packages for your platform, run every topic `install.sh`, offer zsh as the login shell. Idempotent. |
| `dotfiles update` | Fast-forward to `main`, then `install`, then upgrade mise-managed tools. This is what the auto-updater runs. |
| `dotfiles verify` | Check that everything is in place for this platform. |
| `dotfiles defaults` | Apply macOS system/Finder/Dock preferences (`macos/set-defaults.sh`). |
| `dotfiles ssh-key` | Create an ed25519 key for this machine if needed and register it with GitHub via `gh`. |

On first run the git topic asks for your name and email (interactive only). Existing files are backed up with a `.backup` suffix when symlinks are created.

## Platforms

The same repo serves three kinds of machine, using the native package manager on each:

| Platform | Packages | Auto-update | Notes |
|----------|----------|-------------|-------|
| macOS (Apple Silicon) | Homebrew `Brewfile` | launchd agent | `macos/` system defaults |
| Arch-based Linux (CachyOS) | `pacman` + AUR via `yay`/`paru` | systemd user timer | Wayland clipboard via `wl-clipboard` |
| Debian/Ubuntu (24.04 LTS) | `apt` for base packages, **mise** for modern CLI tools | systemd user timer | apt ships tools like `fzf`, `bat`, `fd`, `eza`, `gh` stale or missing, so mise installs upstream releases |

Platform detection lives in `script/os.sh` (`DOTFILES_OS` = `darwin`/`linux`, `DOTFILES_DISTRO` = `arch`/`debian`).
Files tagged with a platform name are only used there:

| File name | Used on |
|-----------|---------|
| `foo.zsh`, `install.sh`, `foo.symlink` | every platform |
| `foo.darwin.zsh`, `install.darwin.sh`, `Brewfile.darwin.symlink` | macOS only (symlinked as `~/.Brewfile`) |
| `foo.linux.zsh`, `install.linux.sh` | any Linux |
| `foo.arch.zsh`, `install.arch.sh` | Arch family |
| `foo.debian.zsh`, `install.debian.sh` | Debian/Ubuntu |

## What's Included

### Topics

| Topic | Purpose |
|-------|---------|
| `antidote/` | Zsh plugin manager (git-cloned to `~/.antidote` on every platform) |
| `apt/` | Debian/Ubuntu base package list and installer |
| `atuin/` | Synced, searchable shell history |
| `bat/` | bat theme (Solarized Dark, matching Ghostty and delta) |
| `autoupdate/` | launchd agent (macOS) or systemd user timer (Linux) that pulls & re-runs installers every 2 hours |
| `fzf/` | Fuzzy finder integration and key bindings |
| `ghostty/` | Ghostty terminal config, shared by macOS and Linux (installed via cask / pacman) |
| `git/` | Git config, aliases, and global ignore |
| `homebrew/` | macOS Brewfile and installer |
| `macos/` | macOS system/Finder/Dock preferences |
| `mise/` | Runtime version manager (replaces asdf) and per-directory env (replaces direnv); on Ubuntu also installs the modern CLI tools |
| `pacman/` | Arch package lists (official + AUR) and installer |
| `system/` | Shell aliases, environment, PATH, and a cross-platform `pbcopy`/`pbpaste`/`open` |
| `vim/` | Vim configuration |
| `xcode/` | iOS Simulator alias (macOS only) |
| `zoxide/` | Smarter `cd` with directory frecency |
| `zsh/` | Zsh config, prompt, and plugin loading |

### Terminal

[Ghostty](https://ghostty.org) is installed on macOS (cask) and Arch (pacman) with one shared config in `ghostty/config`, linked to `~/.config/ghostty/config`. Its shell integration installs Ghostty's terminfo on hosts you `ssh` into, so `TERM` works on the headless Ubuntu box too.

### Modern CLI Replacements

Installed via Homebrew on macOS, pacman on Arch, and mise on Ubuntu:

| Tool | Replaces | What it does |
|------|----------|-------------|
| [`eza`](https://github.com/eza-community/eza) | `ls`, `tree` | Modern ls with git awareness and tree view |
| [`bat`](https://github.com/sharkdp/bat) | `cat` | Cat with syntax highlighting and line numbers |
| [`fd`](https://github.com/sharkdp/fd) | `find` | Fast, user-friendly file finder |
| [`ripgrep`](https://github.com/BurntSushi/ripgrep) | `grep`/`ack` | Blazing-fast recursive code search |
| [`zoxide`](https://github.com/ajeetdsouza/zoxide) | `cd`/`z` | Smarter cd that learns your habits |
| [`git-delta`](https://github.com/dandavison/delta) | `diff` | Beautiful git diffs with syntax highlighting |
| [`atuin`](https://github.com/atuinsh/atuin) | `history` | Synced, searchable shell history |
| [`mise`](https://mise.jdx.dev) | `asdf`, `direnv` | Runtime versions (reads `.tool-versions`) and per-directory env |
| [`tealdeer`](https://github.com/tealdeer-rs/tealdeer) | `man` | Fast `tldr` client with simplified, example-driven pages |
| [`btop`](https://github.com/aristocratos/btop) | `top`/`htop` | Beautiful system resource monitor |

## How It Works

Everything is organized into **topic directories** (e.g., `git/`, `fzf/`, `zsh/`). The zsh loader (`zsh/zshrc.symlink`) auto-discovers files by naming convention, skipping files tagged for another platform:

| Pattern | When loaded | Purpose |
|---------|------------|---------|
| `path.zsh` | First | `$PATH` modifications |
| `*.zsh` | Second | Config, aliases, functions |
| `completion.zsh` | Last | Shell completions |
| `install.sh` | `dotfiles install` | Setup for the topic (package-manager topics run first) |
| `*.symlink` | `dotfiles install` | Symlinked to `$HOME/.filename` |

**`bin/`** is added to `$PATH` — anything in there is available everywhere.

GUI apps are the Brewfile's `cask` entries on macOS and plain packages on Arch (none on the headless Ubuntu box).
Package lists are kept per platform and cross-referenced in their headers:
`homebrew/Brewfile.darwin.symlink`, `pacman/packages.txt` (+ `aur.txt`), `apt/packages.txt`, and `mise/cli-tools.debian.toml`.
When adding a tool, add it to all of them.

## Keeping Up to Date

`dotfiles update` fast-forwards to `main`, re-runs all installers, and upgrades mise-managed tools. The launchd agent and systemd service pull *before* starting the script, so a broken `bin/dotfiles` on `main` can still be fixed by the next push. Offline, the update skips the network-only steps and re-applies the current checkout; one failing installer doesn't stop the others. Manual and scheduled runs can't overlap (a lock in `$TMPDIR`).
It runs every 2 hours from a launchd agent on macOS or a systemd user timer (`dotfiles-update.timer`) on Linux, both installed by the `autoupdate/` topic.
On a headless Linux box the installer enables lingering so the timer runs without a login session.
Logs: `~/Library/Logs/dotfiles-update.log` on macOS, `journalctl --user -u dotfiles-update` on Linux.
Package installs that need a sudo password are skipped when there is no terminal; run `dotfiles update` interactively to pick them up.

## Local Customization

These files are not checked in and won't be overwritten:

- **`~/.localrc`** — sourced at the end of zshrc (zsh syntax is fine; nothing else reads it)
- **`~/.gitconfig.local`** — included by gitconfig for machine-specific git settings
- **`~/.config/mise/config.local.toml`** — machine-specific mise tools

## macOS Defaults

Optionally apply preferred macOS system/Finder/Dock settings:

```console
dotfiles defaults
```

Requires a logout or restart to take full effect. It is a no-op on Linux.

## Testing & CI

A GitHub Actions CI pipeline runs on every push: shellcheck linting, then a full bootstrap + verification on a macOS runner, in a CachyOS container, and on an Ubuntu 24.04 runner. Dependabot keeps the action tags and Docker base images current.

Locally, you can verify an installed machine, or run `script/bootstrap` end to end in a sandbox:

```console
make lint          # shellcheck all shell scripts
make verify        # dotfiles verify for this platform

# macOS (Tart VMs, Apple Silicon)
make macos-setup      # one-time: install Tart, pull macOS Tahoe base image
make macos-test       # automated: clone VM, run bootstrap, verify results, cleanup
make macos-shell      # interactive: clone VM, print SSH info for manual exploration
make macos-ready      # pre-bootstrapped: clone VM, bootstrap + defaults, print SSH info
make macos-cleanup    # stop and delete all leftover dotfiles-test-* VMs

# Linux (Docker; x86-64 images matching the real machines)
make linux-test    # automated: bootstrap + verify in CachyOS and Ubuntu 24.04 containers
make arch-test     # CachyOS only
make ubuntu-test   # Ubuntu only
make arch-shell    # interactive: bootstrap a CachyOS container, open zsh
make ubuntu-shell  # interactive: bootstrap an Ubuntu container, open zsh
```

Containers have no systemd, so the auto-update timer is only verified as installed files there; the Ubuntu CI runner exercises it for real.

## Adding a New Topic

1. Create a directory named after the tool (e.g., `node/`)
2. Add `path.zsh` if PATH changes are needed
3. Add `config.zsh` or `aliases.zsh` for shell configuration
4. Add `install.sh` for one-time setup (source `script/os.sh` for `$DOTFILES_OS`/`$DOTFILES_DISTRO`)
5. Add `*.symlink` files for dotfiles that should land in `$HOME`
6. Tag any platform-specific file with `.darwin`, `.linux`, `.arch` or `.debian` before its extension
7. Add the package to every platform's package list

Existing files are backed up with `.backup` suffix during symlink creation.

## Credits

Forked from [holman/dotfiles](https://github.com/holman/dotfiles), with ideas from [caarlos0/dotfiles](https://github.com/caarlos0/dotfiles), [webpro/dotfiles](https://github.com/webpro/dotfiles) and [natelandau/dotfiles](https://github.com/natelandau/dotfiles).

## License

[MIT](LICENSE)
