[[ ! -x "$(command -v exa)" ]] || alias ls="exa --icons --group-directories-first"
[[ ! -x "$(command -v bat)" ]] || alias cat="bat --style=auto"
[[ ! -x "$(command -v batcat)" ]] || alias cat="batcat --style=auto"
[[ ! -x "$(command -v mktemp)" ]] || alias cdtemp="cd $(mktemp -d)"
[[ -x "$(command -v vim)" || ! -x "$(command -v vi)" ]] || alias vim="vi"
[[ -x "$(command -v open)" || ! -x "$(command -v xdg-open)" ]] || alias open="xdg-open"

## wsl specific configs
# create a alias to notepad++:
[[ ! -x "$(command -v notepad++.exe)" ]] || alias npp="notepad++.exe"
# create a alias to ssh.exe:
[[ ! -x "$(command -v ssh.exe)" ]] || alias ssh="ssh.exe"
# create a alias to git.exe:
[[ ! -x "$(command -v git.exe)" ]] || alias git="git.exe"
