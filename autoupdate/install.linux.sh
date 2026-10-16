#!/bin/sh
# Sets up a systemd user timer to run `dotfiles update` every 2 hours
# (the Linux counterpart of the launchd agent in install.darwin.sh).

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
cp "$dir/dot-update.service" "$dir/dot-update.timer" "$UNIT_DIR/"

if ! command -v systemctl >/dev/null 2>&1 || ! systemctl --user show-environment >/dev/null 2>&1; then
	echo "› systemd user session unavailable (container?); unit files copied, timer not enabled"
	exit 0
fi

systemctl --user daemon-reload
systemctl --user enable --now dot-update.timer
echo "› systemd timer dot-update.timer enabled"

# Keep the user manager (and the timer) running without a login session,
# e.g. on a headless server.
if ! loginctl show-user "$USER" 2>/dev/null | grep -q '^Linger=yes'; then
	if loginctl enable-linger "$USER" 2>/dev/null || sudo -n loginctl enable-linger "$USER" 2>/dev/null; then
		echo "› lingering enabled for $USER"
	else
		echo "› note: run 'sudo loginctl enable-linger $USER' so the timer runs without a login session"
	fi
fi
