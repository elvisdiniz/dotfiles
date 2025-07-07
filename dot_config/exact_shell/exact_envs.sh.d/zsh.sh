if [ -x "$(command -v zsh)" ]; then
    ZSH_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh"
    ZSH_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
    [ -d "$ZSH_STATE_HOME" ] || mkdir -p "$ZSH_STATE_HOME"
    [ -d "$ZSH_CACHE_DIR/completions" ] || mkdir -p "$ZSH_CACHE_DIR/completions"
fi
