#!/bin/sh
#
# Debian/Ubuntu packages via apt, plus mise (from its official apt repo, or the
# upstream installer into ~/.local/bin as a fallback). mise then installs the
# modern CLI tools — see mise/install.debian.sh.
# Other platforms: homebrew/install.darwin.sh, pacman/install.arch.sh.

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

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -q
pkgs="$(packages "$dir/packages.txt")"
# shellcheck disable=SC2086
sudo apt-get install -y -q --no-install-recommends $pkgs

if ! command -v mise >/dev/null 2>&1; then
	echo "› installing mise"
	if sudo apt-get install -y -q extrepo &&
		sudo extrepo enable mise &&
		sudo apt-get update -q &&
		sudo apt-get install -y -q mise; then
		echo "  mise installed from its apt repo"
	else
		echo "  apt route failed; installing mise to ~/.local/bin"
		curl -fsSL https://mise.run | sh
	fi
fi
