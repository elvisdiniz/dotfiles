if [ -x "$(command -v bat)" ]; then
    export BAT_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/bat"
    if [ ! -d "$BAT_CACHE_HOME" ] || [ ! -f "$BAT_CACHE_HOME/themes.bin" ] || [ ! -f "$BAT_CACHE_HOME/syntaxes.bin" ] || [ ! -f "$BAT_CACHE_HOME/metadata.yaml" ]; then
        bat cache --build
    fi
fi