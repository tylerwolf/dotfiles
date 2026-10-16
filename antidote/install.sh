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
BUNDLE="$HOME/.zsh_plugins.zsh"

if [ -d "$ANTIDOTE_HOME/.git" ]; then
	if [ -z "${DOTFILES_OFFLINE:-}" ]; then
		git -C "$ANTIDOTE_HOME" pull -q --ff-only
	fi
elif [ -n "${DOTFILES_OFFLINE:-}" ]; then
	echo "  offline and antidote is not installed; skipping"
	exit 0
else
	git clone -q --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME"
fi

# Write the bundle to a temp file first: a failed bundle (new plugin, no
# network) must not leave an empty plugin file behind.
tmp="$(mktemp "${TMPDIR:-/tmp}/zsh_plugins.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
if zsh "$ANTIDOTE_HOME/antidote" bundle <"$DOTFILES_ROOT/antidote/zsh_plugins.txt" >"$tmp"; then
	mv "$tmp" "$BUNDLE"
else
	echo "  antidote bundle failed; keeping the existing $BUNDLE"
	exit 1
fi

if [ -z "${DOTFILES_OFFLINE:-}" ]; then
	zsh "$ANTIDOTE_HOME/antidote" update
fi
