[[ -x "$(command -v eza)" ]] && alias ls="eza"
[[ -x "$(command -v eza)" ]] && alias ll="eza -lg"
[[ -x "$(command -v eza)" ]] && alias la="eza -a"
[[ -x "$(command -v eza)" ]] && alias lla="eza -lga"
[[ -x "$(command -v eza)" ]] || alias ll="ls -lh"
[[ -x "$(command -v eza)" ]] || alias la="ls -a"
[[ -x "$(command -v eza)" ]] || alias lla="ls -lha"
[[ ! -x "$(command -v mktemp)" ]] || alias cdtemp="cd $(mktemp -d)"
[[ -x "$(command -v vim)" || ! -x "$(command -v vi)" ]] || alias vim="vi"
[[ -x "$(command -v dig)" || ! -x "$(command -v kdig)" ]] || alias dig="kdig"
[[ -x "$(command -v open)" || ! -x "$(command -v xdg-open)" ]] || alias open="xdg-open"
[ -x "$(command -v wget)" ] && alias wget="wget --hsts-file=${XDG_DATA_HOME:-$HOME/.local/share}/wget-hsts"

## wsl specific configs
# create a alias to notepad++:
[[ ! -x "$(command -v notepad++.exe)" ]] || alias npp="notepad++.exe"
# create a alias to ssh.exe:
[[ ! -x "$(command -v ssh.exe)" ]] || alias ssh="ssh.exe"
# create a alias to git.exe:
[[ ! -x "$(command -v git.exe)" ]] || alias git="git.exe"
