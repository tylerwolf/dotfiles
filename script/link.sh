#!/bin/sh
# link_config SRC DST — symlink a config file, backing up anything already there.
# Sourced by topic installers that manage files under ~/.config (not an installer itself).
link_config() {
	if [ -L "$2" ]; then
		if [ "$(readlink "$2")" = "$1" ]; then
			return 0
		fi
		rm "$2"
	elif [ -e "$2" ]; then
		mv "$2" "$2.backup"
		echo "  moved $2 to $2.backup"
	fi
	ln -sf "$1" "$2"
	echo "  linked $2"
}
