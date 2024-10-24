if test -z "$GNUPGHOME"; then
    export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
fi
