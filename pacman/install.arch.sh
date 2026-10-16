#!/bin/sh
#
# Arch-family packages (CachyOS): official repos via pacman, AUR via yay/paru.
# Other platforms: homebrew/install.darwin.sh, apt/install.debian.sh.

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

dir="$(cd "$(dirname "$0")" && pwd -P)"

# strip comments and blank lines from a package list
packages() {
	sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1" | tr '\n' ' '
}

# Under the systemd timer there is no tty, so a sudo password prompt would hang.
if ! sudo -n true 2>/dev/null && [ ! -t 0 ]; then
	echo "  sudo needs a password and there is no terminal; skipping package sync"
	echo "  (run dot_update interactively to install new packages)"
	exit 0
fi

pkgs="$(packages "$dir/packages.txt")"
# shellcheck disable=SC2086
sudo pacman -S --needed --noconfirm $pkgs

aur="$(packages "$dir/aur.txt")"
if [ -n "$aur" ]; then
	if command -v yay >/dev/null 2>&1; then
		# shellcheck disable=SC2086
		yay -S --needed --noconfirm $aur
	elif command -v paru >/dev/null 2>&1; then
		# shellcheck disable=SC2086
		paru -S --needed --noconfirm $aur
	else
		echo "  no AUR helper (yay/paru) found; skipping: $aur"
	fi
fi
