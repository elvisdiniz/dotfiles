if [ -x "$(command -v zsh)" ]; then
    ZSH_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh"
    [ -d "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh" ] || mkdir -p "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
    [ -d "$ZSH_STATE_HOME" ] || mkdir -p "$ZSH_STATE_HOME"
fi