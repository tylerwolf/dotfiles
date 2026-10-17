#!/bin/sh
#
# Homebrew (macOS only)
#
# Installs Homebrew if missing, then installs everything in ~/.Brewfile.
# Other platforms: pacman/install.arch.sh, apt/install.debian.sh.

set -e

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

if ! command -v brew >/dev/null 2>&1; then
	echo "  Installing Homebrew for you."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -n "${DOTFILES_OFFLINE:-}" ]; then
	echo "  offline; skipping brew update/bundle"
	exit 0
fi

# Upgrade installed formulae only when `dotfiles` says so (interactive runs);
# otherwise just install what's missing.
if [ -n "${DOTFILES_UPGRADE:-}" ]; then
	echo "  installing missing packages and upgrading"
else
	echo "  installing missing packages only (no upgrades)"
	export HOMEBREW_BUNDLE_NO_UPGRADE=1
fi

brew update
brew bundle --global
brew cleanup || true
