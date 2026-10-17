# Remind me to run `dotfiles update` by hand once in a while: the scheduled
# runs apply the repo but skip anything that needs sudo, and (on macOS) are
# where package upgrades happen only when run interactively.
# Threshold in days; set DOTFILES_UPDATE_REMINDER_DAYS before zshrc (e.g. in
# ~/.zshenv) to change it, or 0 to disable.
() {
  local days="${DOTFILES_UPDATE_REMINDER_DAYS:-14}"
  (( days > 0 )) || return 0
  zmodload zsh/datetime 2>/dev/null || return 0
  local stamp="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/last-manual-update"
  local last=0
  [[ -r $stamp ]] && last=$(<"$stamp")
  if (( last == 0 )); then
    print -P "  %F{yellow}dotfiles:%f no manual update recorded; run %Bdotfiles update%b when convenient"
    return 0
  fi
  local age=$(( (EPOCHSECONDS - last) / 86400 ))
  if (( age >= days )); then
    print -P "  %F{yellow}dotfiles:%f last manual update was $age days ago; run %Bdotfiles update%b when convenient"
  fi
}
