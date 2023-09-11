[[ ! -x "$(command -v vim)" ]] || export EDITOR=vim
[[ -x "$(command -v vim)" || ! -x "$(command -v vi)" ]] || export EDITOR=vi
