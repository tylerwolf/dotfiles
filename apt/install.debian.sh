#!/bin/sh
#
# Debian/Ubuntu packages via apt, plus mise (from its official apt repo, or the
# upstream installer into ~/.local/bin as a fallback). mise then installs the
# modern CLI tools — see mise/install.debian.sh.
# Checks what is missing first and only calls sudo when something has to be
# installed. Other platforms: homebrew/install.darwin.sh, pacman/install.arch.sh.

set -e

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

dir="$(cd "$(dirname "$0")" && pwd -P)"

# strip comments and blank lines from a package list
packages() {
	sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1" | tr '\n' ' '
}

missing=""
for pkg in $(packages "$dir/packages.txt"); do
	dpkg -s "$pkg" >/dev/null 2>&1 || missing="$missing $pkg"
done

need_mise=false
command -v mise >/dev/null 2>&1 || need_mise=true

if [ -z "$missing" ] && [ "$need_mise" = false ]; then
	echo "  all packages installed"
	exit 0
fi

# Under the systemd timer there is no tty, so a sudo password prompt would hang.
if ! sudo -n true 2>/dev/null && [ ! -t 0 ]; then
	echo "  packages to install:$missing$([ "$need_mise" = true ] && echo " mise")"
	echo "  sudo needs a password and there is no terminal; run 'dotfiles update' interactively"
	exit 0
fi

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -q

if [ -n "$missing" ]; then
	# shellcheck disable=SC2086
	sudo apt-get install -y -q --no-install-recommends $missing
fi

if [ "$need_mise" = true ]; then
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
