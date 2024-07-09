if [ -x "$(command -v cargo)" ]; then
    export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
    mkdir -p "${CARGO_HOME}"
fi