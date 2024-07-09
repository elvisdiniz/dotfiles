if [[ -z $SSH_CONNECTION && $(is_ssh) == "yes" ]]; then
    export SSH_CONNECTION=$(is_ssh)
fi
