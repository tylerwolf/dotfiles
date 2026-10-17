alias gl='git pull --prune'
alias glog="git log --graph --decorate --oneline --abbrev-commit"
alias glga="glog --all"
alias gp='git push origin HEAD'
alias gpa='git push origin --all'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gb='git branch -v'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add --patch'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gs='git status -sb'
alias glnext='git log --oneline $(git describe --tags --abbrev=0 @^)..@'
alias gf='git fetch --all --prune'
alias gm='git merge'
alias gsts='git stash show --text'
alias gsta='git stash'
alias gstp='git stash pop'
alias gstd='git stash drop'

gi() {
	curl -sL "https://www.gitignore.io/api/$*"
}