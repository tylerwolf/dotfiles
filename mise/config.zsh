#!/bin/zsh

# runtime versions (node, ...) and per-directory env; replaces asdf + direnv
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi
