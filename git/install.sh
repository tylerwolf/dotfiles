#!/bin/sh

eval "$(/opt/homebrew/bin/brew shellenv)"

# Use main as the default branch for new repos
git config --global init.defaultBranch main

# Point git at the global ignore file symlinked by bootstrap
git config --global core.excludesfile ~/.gitignore

# Don't ask ssh password all the time
# if [ "$(uname -s)" = "Darwin" ]; then
# 	git config --global credential.helper osxkeychain
# else
# 	git config --global credential.helper cache
# fi

# better diffs with delta
if command -v delta >/dev/null 2>&1; then
	git config --global core.pager delta
	git config --global interactive.diffFilter "delta --color-only"
	git config --global delta.navigate true
	git config --global delta.line-numbers true
	git config --global delta.syntax-theme "Dracula"
	git config --global merge.conflictstyle diff3
	git config --global diff.colorMoved default
fi
