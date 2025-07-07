# [[ -x "$(command -v eza)" ]] && alias ls="eza"
# [[ -x "$(command -v eza)" ]] && alias ll="eza -lg"
# [[ -x "$(command -v eza)" ]] && alias la="eza -a"
# [[ -x "$(command -v eza)" ]] && alias lla="eza -lga"
# [[ -x "$(command -v eza)" ]] || alias ll="ls -lh"
# [[ -x "$(command -v eza)" ]] || alias la="ls -a"
# [[ -x "$(command -v eza)" ]] || alias lla="ls -lha"
[[ ! -x "$(command -v mktemp)" ]] || alias cdtemp="cd $(mktemp -d)"
[[ -x "$(command -v vim)" || ! -x "$(command -v vi)" ]] || alias vim="vi"
[[ -x "$(command -v dig)" || ! -x "$(command -v kdig)" ]] || alias dig="kdig"
[[ -x "$(command -v open)" || ! -x "$(command -v xdg-open)" ]] || alias open="xdg-open"
[ -x "$(command -v wget)" ] && alias wget="wget --hsts-file=${XDG_DATA_HOME:-$HOME/.local/share}/wget-hsts"

# alias docker to podman if docker is not installed an podman is
[[ ! -x "$(command -v docker)" && -x "$(command -v podman)" ]] && alias docker="podman"

## wsl specific configs
# create a alias to notepad++:
[[ ! -x "$(command -v notepad++.exe)" ]] || alias npp="notepad++.exe"
# create a alias to ssh.exe:
[[ ! -x "$(command -v ssh.exe)" ]] || alias ssh="ssh.exe"
# create a alias to git.exe:
[[ ! -x "$(command -v git.exe)" ]] || alias git="git.exe"

# create lazydocker alias
[[ -x "$(command -v lazydocker)" ]] && alias lzd="lazydocker"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
