#!/bin/sh
#
# Ghostty terminal — the app comes from the platform package manager
# (homebrew cask / pacman); this links the shared config. Linking is harmless
# on headless hosts where Ghostty isn't installed.

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"

mkdir -p "$HOME/.config/ghostty"

# shellcheck source=script/link.sh
. "$DOTFILES_ROOT/script/link.sh"
link_config "$DOTFILES_ROOT/ghostty/config" "$HOME/.config/ghostty/config"
