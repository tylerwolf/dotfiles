#!/bin/sh
#
# mise — runtime version manager (replaces asdf) and per-directory env
# (replaces direnv). The binary comes from the platform package manager
# (homebrew/pacman/apt topics); this links the global config and installs
# the configured runtimes.

set -e

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"

if ! command -v mise >/dev/null 2>&1; then
	echo "  mise is not installed; skipping"
	exit 0
fi

mkdir -p "$HOME/.config/mise/conf.d"

# shellcheck source=script/link.sh
. "$DOTFILES_ROOT/script/link.sh"
link_config "$DOTFILES_ROOT/mise/global.toml" "$HOME/.config/mise/config.toml"

MISE_YES=1 mise install
