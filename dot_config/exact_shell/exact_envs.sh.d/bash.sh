if [ -x "$(command -v bash)" ]; then
    BASH_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}/bash"
    [ -d "${BASH_STATE_HOME}" ] || mkdir -p "${BASH_STATE_HOME}"
fi