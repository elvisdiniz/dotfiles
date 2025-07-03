# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private .local/bin if it exists
export BIN_HOME="${HOME}/.local/bin"
[ -d "$BIN_HOME" ] || mkdir -p "$BIN_HOME"
PATH="$BIN_HOME:$PATH"

# set PATH so it includes user's private .local/bin if it exists
export SCRIPTS_HOME="${HOME}/.local/scripts"
[ -d "$SCRIPTS_HOME" ] || mkdir -p "$SCRIPTS_HOME"
PATH="$SCRIPTS_HOME:$PATH"

export NPM_BIN="${HOME}/.local/share/npm/bin"
[ -d "$NPM_BIN" ] && PATH="$NPM_BIN:$PATH"

