#!/bin/sh
#
# os.sh — platform detection shared by bootstrap, the dotfiles command and
# every topic installer. Source it, don't run it:
#
#   . "$(dirname "$0")/../script/os.sh"
#
# Exports:
#   DOTFILES_OS      darwin | linux | unknown
#   DOTFILES_DISTRO  arch | debian | "" (empty on macOS or unknown distro)
#   DOTFILES_TAGS    active tags, space separated, e.g. "darwin" or "linux arch"
#
# A file named foo.<tag>.zsh / install.<tag>.sh / foo.<tag>.symlink is only used
# when <tag> is in DOTFILES_TAGS. The zsh loader duplicates this logic in
# zsh/zshrc.symlink (kept fork-free for shell startup speed).

case "$(uname -s)" in
Darwin) DOTFILES_OS=darwin ;;
Linux) DOTFILES_OS=linux ;;
*) DOTFILES_OS=unknown ;;
esac

DOTFILES_DISTRO=""
if [ "$DOTFILES_OS" = linux ]; then
	ids=""
	if [ -r /etc/os-release ]; then
		# shellcheck disable=SC1091,SC2154
		ids="$(. /etc/os-release 2>/dev/null; printf ' %s %s ' "$ID" "$ID_LIKE")"
	fi
	case "$ids" in
	*" arch "* | *" cachyos "* | *" endeavouros "* | *" manjaro "*) DOTFILES_DISTRO=arch ;;
	*" debian "* | *" ubuntu "*) DOTFILES_DISTRO=debian ;;
	esac
	if [ -z "$DOTFILES_DISTRO" ]; then
		if [ -f /etc/arch-release ]; then
			DOTFILES_DISTRO=arch
		elif [ -f /etc/debian_version ]; then
			DOTFILES_DISTRO=debian
		fi
	fi
	unset ids
fi

DOTFILES_TAGS="$DOTFILES_OS${DOTFILES_DISTRO:+ $DOTFILES_DISTRO}"
export DOTFILES_OS DOTFILES_DISTRO DOTFILES_TAGS

# Homebrew on macOS (installers may run from launchd with a minimal PATH)
if [ "$DOTFILES_OS" = darwin ] && [ -x /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ~/.local/bin: where mise's fallback installer lands (and standard XDG user bin)
case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH
