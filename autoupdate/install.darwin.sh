#!/bin/sh
# Sets up a launchd agent to run dot_update every 2 hours.

PLIST_NAME="com.dotfiles.update"
PLIST_SRC="$HOME/.dotfiles/autoupdate/${PLIST_NAME}.plist"
PLIST_DST="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"

# Remove legacy crontab entry if present
if crontab -l 2>/dev/null | grep -q dot_update; then
	echo "› removing old crontab entry"
	crontab -l | grep -v "dot_update" | crontab -
fi

# Ensure LaunchAgents directory exists
mkdir -p "$HOME/Library/LaunchAgents"

# Unload old agent if loaded (ignore errors)
launchctl bootout "gui/$(id -u)/${PLIST_NAME}" 2>/dev/null

# Install plist (expand $HOME in the template)
sed "s|\$HOME|$HOME|g" "$PLIST_SRC" > "$PLIST_DST"

# Load the agent
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST"

echo "› launchd agent ${PLIST_NAME} installed"
