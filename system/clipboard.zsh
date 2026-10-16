# Cross-platform clipboard: pbcopy/pbpaste work everywhere.
#   macOS: native. Linux: wl-clipboard (Wayland) → xclip (X11) → OSC 52 escape
#   (copy-only; works over SSH and inside tmux/VMs when the terminal supports it).
if ! command -v pbcopy &>/dev/null; then
  pbcopy() {
    if [[ -n $WAYLAND_DISPLAY ]] && command -v wl-copy &>/dev/null; then
      wl-copy
    elif [[ -n $DISPLAY ]] && command -v xclip &>/dev/null; then
      xclip -selection clipboard
    else
      printf '\e]52;c;%s\a' "$(base64 | tr -d '\n')" >/dev/tty
    fi
  }
  pbpaste() {
    if [[ -n $WAYLAND_DISPLAY ]] && command -v wl-paste &>/dev/null; then
      wl-paste --no-newline
    elif [[ -n $DISPLAY ]] && command -v xclip &>/dev/null; then
      xclip -selection clipboard -o
    else
      print -u2 "pbpaste: no clipboard available (OSC 52 is copy-only)"
      return 1
    fi
  }
fi

# `open` on Linux
if ! command -v open &>/dev/null && command -v xdg-open &>/dev/null; then
  alias open='xdg-open'
fi

# Pipe my public key to my clipboard.
alias pubkey="cat ~/.ssh/id_rsa.pub | pbcopy && echo '=> Public key copied to pasteboard.'"
