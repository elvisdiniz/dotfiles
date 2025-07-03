# set PATH so it includes user's private bin if it exists
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# set PATH so it includes user's private .local/bin if it exists
export BIN_HOME="${HOME}/.local/bin"
[[ -d "$BIN_HOME" ]] || mkdir -p "$BIN_HOME"
export PATH="$BIN_HOME:$PATH"

# set PATH so it includes user's private .local/bin if it exists
export SCRIPTS_HOME="${HOME}/.local/scripts"
[[ -d "$SCRIPTS_HOME" ]] || mkdir -p "$SCRIPTS_HOME"
export PATH="$SCRIPTS_HOME:$PATH"

export NPM_BIN="${HOME}/.local/share/npm/bin"
[[ -d "$NPM_BIN" ]] && export PATH="$NPM_BIN:$PATH"

[[ -x "$(command -v asdf)" ]] && export PATH="${ASDF_DATA_DIR:-$HOME/.local/share/asdf}/shims:$PATH"
