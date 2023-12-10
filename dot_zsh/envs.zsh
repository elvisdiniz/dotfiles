[[ ! -x "$(command -v vim)" ]] || export EDITOR=vim
[[ -x "$(command -v vim)" || ! -x "$(command -v vi)" ]] || export EDITOR=vi

[[ ! -f ~/.acme.sh/acme.sh.env ]] || ~/.acme.sh/acme.sh.env
