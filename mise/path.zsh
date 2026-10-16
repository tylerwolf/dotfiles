# mise: runtime versions (node, ...) and, on Ubuntu, the modern CLI tools.
# Activated in the path phase so later topic files (atuin, fzf, ...) can find
# the binaries mise manages. Falls back to mise's own install dir in case
# ~/.local/bin isn't on PATH yet.
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
elif [[ -x $HOME/.local/bin/mise ]]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
fi
