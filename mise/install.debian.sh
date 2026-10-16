#!/bin/sh
#
# Debian/Ubuntu only: have mise install the modern CLI tools that apt ships
# stale or missing (see mise/cli-tools.debian.toml).

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
link_config "$DOTFILES_ROOT/mise/cli-tools.debian.toml" "$HOME/.config/mise/conf.d/cli-tools.toml"

MISE_YES=1 mise install
