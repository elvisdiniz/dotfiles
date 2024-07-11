export ASDF_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/asdf"

if [ -f "$ASDF_DATA_DIR/asdf.sh" ]; then
    source "$ASDF_DATA_DIR/asdf.sh"
    export ASDF_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/asdf/asdfrc"
    [ -n "$fpath" ] && fpath=(${ASDF_DATA_DIR}/completions $fpath)
fi
