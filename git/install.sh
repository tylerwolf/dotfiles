#!/bin/sh
#
# git: identity (asked once, on a terminal), defaults, credential helper, delta.

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

# Identity. On a fresh machine ask for it; if a ~/.gitconfig that we don't
# manage already has one, keep it and mark the file as ours from now on.
if [ -z "$(git config --global --get user.email)" ]; then
	if [ -t 0 ]; then
		printf "  [ \033[0;33m??\033[0m ] git author name: "
		read -r user_name
		printf "  [ \033[0;33m??\033[0m ] git author email: "
		read -r user_email
		git config --global user.name "$user_name"
		git config --global user.email "$user_email"
	else
		echo "  no git identity set and no terminal; set user.name/user.email later"
	fi
elif [ "$(git config --global --get dotfiles.managed)" != "true" ]; then
	user_name="$(git config --global --get user.name)"
	user_email="$(git config --global --get user.email)"
	mv ~/.gitconfig ~/.gitconfig.backup
	echo "  moved ~/.gitconfig to ~/.gitconfig.backup"
	git config --global user.name "$user_name"
	git config --global user.email "$user_email"
fi
git config --global include.path ~/.gitconfig.local
git config --global dotfiles.managed true

# Use main as the default branch for new repos
git config --global init.defaultBranch main

# Point git at the global ignore file symlinked by `dotfiles install`
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
