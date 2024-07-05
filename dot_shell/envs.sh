[[ ! -x "$(command -v vim)" ]] || export EDITOR=vim
# [[ ! -x "$(command -v nvim)" ]] || export EDITOR=nvim
[[ -x "$(command -v vim)" || ! -x "$(command -v vi)" ]] || export EDITOR=vi

[[ ! -f ~/.acme.sh/acme.sh.env ]] || source ~/.acme.sh/acme.sh.env

if [[ -z $SSH_CONNECTION && $(is_ssh) == "yes" ]]; then
  export SSH_CONNECTION=$(is_ssh)
fi
