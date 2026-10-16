# modern ls using eza (falls back to GNU ls: gls from Homebrew coreutils on macOS,
# the system ls on Linux)
if command -v eza &>/dev/null; then
  alias l='eza -lF'
  alias la='eza -laF'
  alias lr='eza -lR --sort=modified'
  alias lt='eza -l --sort=modified'
  alias ll='eza -l'
  alias ldot='eza -ld .*'
elif command -v gls &>/dev/null; then
  alias l='gls -lFh --color'
  alias la='gls -lAFh --color'
  alias lr='gls -tRFh --color'
  alias lt='gls -ltFh --color'
  alias ll='gls -l --color'
  alias ldot='gls -ld --color .*'
elif ls --color=auto -d . &>/dev/null; then
  alias l='ls -lFh --color=auto'
  alias la='ls -lAFh --color=auto'
  alias lr='ls -tRFh --color=auto'
  alias lt='ls -ltFh --color=auto'
  alias ll='ls -l --color=auto'
  alias ldot='ls -ld --color=auto .*'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# because typing 'cd' is A LOT of work!!
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
