#!/bin/zsh

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# don't nice background tasks
setopt NO_BG_NICE
setopt NO_HUP
setopt NO_BEEP
# allow functions to have local options
setopt LOCAL_OPTIONS
# allow functions to have local traps
setopt LOCAL_TRAPS
# share history between sessions ???
setopt SHARE_HISTORY
# add timestamps to history
setopt EXTENDED_HISTORY
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
# adds history
setopt APPEND_HISTORY
# adds history incrementally and share it across sessions
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
# don't record dupes in history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt HIST_EXPIRE_DUPS_FIRST
# dont ask for confirmation in rm globs*
setopt RM_STAR_SILENT

# up/down arrows: atuin's history search when it loaded, else prefix search
if ! (( $+widgets[atuin-up-search] )); then
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search

  # fuzzy find: start to type
  bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
  bindkey "$terminfo[kcud1]" down-line-or-beginning-search
  bindkey "$terminfo[cuu1]" up-line-or-beginning-search
  bindkey "$terminfo[cud1]" down-line-or-beginning-search
fi

# backward and forward word with option+left/right
bindkey '^[^[[D' backward-word
bindkey '^[b' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[f' forward-word

# go to the beginning/end of line with fn+left/right, home/end, or ctrl+a/e
bindkey "${terminfo[khome]}" beginning-of-line
bindkey '^[[H' beginning-of-line
bindkey '^A' beginning-of-line
bindkey "${terminfo[kend]}"  end-of-line
bindkey '^[[F' end-of-line
bindkey '^E' end-of-line

# delete char with backspaces and delete
bindkey '^[[3~' delete-char
bindkey '^?' backward-delete-char

# delete word with ctrl+backspace or ctrl+w
bindkey '^[[3;5~' backward-delete-word
bindkey '^W' backward-delete-word
# bindkey '^[[3~' backward-delete-word

# Ctrl+R: atuin owns it when loaded (fzf keeps Ctrl+T / Alt+C), else fzf,
# else plain history search. Explicit, since topic files load alphabetically
# and whichever bound ^R last would otherwise win.
if (( $+widgets[atuin-search] )); then
  bindkey '^R' atuin-search
elif (( $+widgets[fzf-history-widget] )); then
  bindkey '^R' fzf-history-widget
else
  bindkey '^R' history-incremental-search-backward
fi