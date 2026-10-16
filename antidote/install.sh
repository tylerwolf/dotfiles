#!/bin/sh
#
# antidote — zsh plugin manager. Installed by git clone on every platform
# (upstream's recommended method; Arch and Ubuntu don't package a current
# version). Generates the static ~/.zsh_plugins.zsh that zshrc sources.

set -e

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
ANTIDOTE_HOME="$HOME/.antidote"

if [ -d "$ANTIDOTE_HOME/.git" ]; then
	git -C "$ANTIDOTE_HOME" pull -q --ff-only
else
	git clone -q --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME"
fi

zsh "$ANTIDOTE_HOME/antidote" bundle <"$DOTFILES_ROOT/antidote/zsh_plugins.txt" >~/.zsh_plugins.zsh
zsh "$ANTIDOTE_HOME/antidote" update
