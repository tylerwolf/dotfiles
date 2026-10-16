# Find all .sh files and shell scripts in bin/ and script/ (excluding Dockerfiles)
SHELL_FILES := $(wildcard */*.sh) $(filter-out script/docker, $(wildcard script/*))
BIN_SCRIPTS := $(wildcard bin/*)

.PHONY: lint verify macos-setup macos-test macos-shell macos-ready macos-cleanup \
        linux-test arch-test ubuntu-test arch-shell ubuntu-shell
lint:
	shellcheck $(SHELL_FILES) $(BIN_SCRIPTS)

verify:
	./script/verify

# macOS (Tart VMs)
macos-setup:
	./script/test-macos setup

macos-test:
	./script/test-macos test

macos-shell:
	-./script/test-macos shell

macos-ready:
	-./script/test-macos ready

macos-cleanup:
	./script/test-macos cleanup

# Linux (Docker containers)
linux-test: arch-test ubuntu-test

arch-test:
	./script/test-linux test arch

ubuntu-test:
	./script/test-linux test ubuntu

arch-shell:
	-./script/test-linux shell arch

ubuntu-shell:
	-./script/test-linux shell ubuntu
