#!/bin/sh
#
# Linux only: link the Linux-specific Ghostty settings next to the shared config.

set -e

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"

mkdir -p "$HOME/.config/ghostty"

# shellcheck source=script/link.sh
. "$DOTFILES_ROOT/script/link.sh"
link_config "$DOTFILES_ROOT/ghostty/config.linux" "$HOME/.config/ghostty/config.linux"
