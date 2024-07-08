# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private .local/bin if it exists
export BIN_HOME="${HOME}/.local/bin"
[ -d "$BIN_HOME" ] || mkdir -p "$BIN_HOME"
PATH="$BIN_HOME:$PATH"