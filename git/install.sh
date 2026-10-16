#!/bin/sh

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

# Use main as the default branch for new repos
git config --global init.defaultBranch main

# Point git at the global ignore file symlinked by bootstrap
git config --global core.excludesfile ~/.gitignore

# Don't ask for credentials all the time
if [ "$DOTFILES_OS" = darwin ]; then
	git config --global --replace-all credential.helper osxkeychain
else
	git config --global --replace-all credential.helper cache
fi

# better diffs with delta (on Ubuntu delta is installed by mise, which only
# activates in zsh, so ask mise where it is)
has_delta() {
	command -v delta >/dev/null 2>&1 && return 0
	command -v mise >/dev/null 2>&1 && mise which delta >/dev/null 2>&1
}
if has_delta; then
	git config --global core.pager delta
	git config --global interactive.diffFilter "delta --color-only"
	git config --global delta.navigate true
	git config --global delta.line-numbers true
	git config --global delta.syntax-theme "Solarized (dark)"
	git config --global merge.conflictstyle diff3
	git config --global diff.colorMoved default
fi
