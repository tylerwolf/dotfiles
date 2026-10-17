#!/bin/sh
#
# Arch-family packages (CachyOS): official repos via pacman, AUR via yay/paru.
# Asks pacman what is missing first (no privileges needed) and only calls sudo
# when something actually has to be installed.
# Other platforms: homebrew/install.darwin.sh, apt/install.debian.sh.

set -e

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

dir="$(cd "$(dirname "$0")" && pwd -P)"

# strip comments and blank lines from a package list
packages() {
	sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1" | tr '\n' ' '
}

# names from a list that are not installed (pacman -T honours `provides`, so a
# package satisfied by another one, e.g. gvim for vim, is not reported missing)
missing() {
	[ "$#" -gt 0 ] || return 0
	pacman -T "$@" | tr '\n' ' ' || true
}

# Without a tty a sudo password prompt would hang (the systemd timer).
can_sudo() {
	sudo -n true 2>/dev/null || [ -t 0 ]
}

# Interactive runs (DOTFILES_UPGRADE set by `dotfiles`) do a full system
# upgrade first; Arch's partial-upgrade rule means that's the only safe way to
# refresh the package database. Scheduled runs never upgrade.
if [ -n "${DOTFILES_UPGRADE:-}" ]; then
	if can_sudo; then
		echo "› full system upgrade (pacman -Syu)"
		sudo pacman -Syu --noconfirm
		if [ -n "$(packages "$dir/aur.txt")" ] && command -v yay >/dev/null 2>&1; then
			yay -Sua --noconfirm
		fi
		echo "  note: if the kernel or graphics stack was upgraded, reboot when convenient"
	else
		echo "  upgrades requested but sudo needs a password and there is no terminal; skipping"
	fi
fi

# shellcheck disable=SC2046
missing_pkgs="$(missing $(packages "$dir/packages.txt"))"
# shellcheck disable=SC2046
missing_aur="$(missing $(packages "$dir/aur.txt"))"

if [ -z "$missing_pkgs" ] && [ -z "$missing_aur" ]; then
	echo "  all packages installed"
	exit 0
fi

if ! can_sudo; then
	echo "  packages to install:${missing_pkgs:+ $missing_pkgs}${missing_aur:+ $missing_aur}"
	echo "  sudo needs a password and there is no terminal; run 'dotfiles update' interactively"
	exit 0
fi

if [ -n "$missing_pkgs" ]; then
	# No -y on scheduled runs: a partial upgrade is worse than a stale database.
	# If this fails with 404s, run 'dotfiles update' from a terminal (which does
	# the full -Syu first).
	# shellcheck disable=SC2086
	sudo pacman -S --needed --noconfirm $missing_pkgs
fi

if [ -n "$missing_aur" ]; then
	if command -v yay >/dev/null 2>&1; then
		# shellcheck disable=SC2086
		yay -S --needed --noconfirm $missing_aur
	elif command -v paru >/dev/null 2>&1; then
		# shellcheck disable=SC2086
		paru -S --needed --noconfirm $missing_aur
	else
		echo "  no AUR helper (yay/paru) found; skipping: $missing_aur"
	fi
fi
