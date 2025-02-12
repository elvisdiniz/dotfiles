if test -x "$(command -v bat)"
    set -gx BAT_CACHE_HOME "$XDG_CACHE_HOME/bat"
    if not test -d "$BAT_CACHE_HOME"
      or not test -f "$BAT_CACHE_HOME/themes.bin"
      or not test -f "$BAT_CACHE_HOME/syntaxes.bin"
      or not test -f "$BAT_CACHE_HOME/metadata.yaml"
      bat cache --build
    end
end
