#!/bin/sh
# Sets up a systemd user timer to run `dotfiles update` every 2 hours
# (the Linux counterpart of the launchd agent in install.darwin.sh).
# Idempotent: unit files are only copied when changed, and the timer is only
# enabled when it isn't already.

set -e

# shellcheck source=script/os.sh
. "$(dirname "$0")/../script/os.sh"

dir="$(cd "$(dirname "$0")" && pwd -P)"
UNIT_DIR="$HOME/.config/systemd/user"

# Remove legacy crontab entry if present
if crontab -l 2>/dev/null | grep -q dot_update; then
	echo "› removing old crontab entry"
	crontab -l | grep -v "dot_update" | crontab -
fi

mkdir -p "$UNIT_DIR"
changed=false
for unit in dotfiles-update.service dotfiles-update.timer; do
	if ! cmp -s "$dir/$unit" "$UNIT_DIR/$unit"; then
		cp "$dir/$unit" "$UNIT_DIR/$unit"
		changed=true
	fi
done

if ! command -v systemctl >/dev/null 2>&1 || ! systemctl --user show-environment >/dev/null 2>&1; then
	echo "› systemd user session unavailable (container?); unit files copied, timer not enabled"
	exit 0
fi

if [ "$changed" = true ]; then
	systemctl --user daemon-reload
fi

if systemctl --user is-enabled dotfiles-update.timer >/dev/null 2>&1; then
	echo "› systemd timer dotfiles-update.timer up to date"
else
	systemctl --user enable --now dotfiles-update.timer
	echo "› systemd timer dotfiles-update.timer enabled"
fi

# Keep the user manager (and the timer) running without a login session,
# e.g. on a headless server.
if ! loginctl show-user "$USER" 2>/dev/null | grep -q '^Linger=yes'; then
	if loginctl enable-linger "$USER" 2>/dev/null || sudo -n loginctl enable-linger "$USER" 2>/dev/null; then
		echo "› lingering enabled for $USER"
	else
		echo "› note: run 'sudo loginctl enable-linger $USER' so the timer runs without a login session"
	fi
fi
