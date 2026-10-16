#!/bin/sh
# Sets up a launchd agent to run `dotfiles update` every 2 hours.
#
# Only touches launchd when the plist actually changed, and never reloads the
# agent from inside one of its own runs (DOTFILES_LAUNCHD is set by the plist):
# bootout would kill the update that is running this script.

set -e

PLIST_NAME="com.dotfiles.update"
PLIST_SRC="$HOME/.dotfiles/autoupdate/${PLIST_NAME}.plist"
PLIST_DST="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"
LABEL="gui/$(id -u)/${PLIST_NAME}"

# Remove legacy crontab entry if present
if crontab -l 2>/dev/null | grep -q dot_update; then
	echo "› removing old crontab entry"
	crontab -l | grep -v "dot_update" | crontab -
fi

mkdir -p "$HOME/Library/LaunchAgents"

# Render the plist (expand $HOME in the template)
rendered="$(sed "s|\$HOME|$HOME|g" "$PLIST_SRC")"

loaded=false
launchctl print "$LABEL" >/dev/null 2>&1 && loaded=true

if [ -f "$PLIST_DST" ] && [ "$(cat "$PLIST_DST")" = "$rendered" ] && [ "$loaded" = true ]; then
	echo "› launchd agent ${PLIST_NAME} up to date"
	exit 0
fi

printf '%s\n' "$rendered" >"$PLIST_DST"

if [ -n "${DOTFILES_LAUNCHD:-}" ]; then
	echo "› launchd agent config updated; it reloads at next login (or run 'dotfiles install' from a terminal)"
	exit 0
fi

launchctl bootout "$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST"
echo "› launchd agent ${PLIST_NAME} installed"
