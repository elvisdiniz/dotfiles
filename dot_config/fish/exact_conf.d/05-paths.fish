# Set PATH to include user's private bin if it exists
if test -d "$HOME/bin"
    fish_add_path "$HOME/bin"
end

# Set PATH to include user's private .local/bin if it exists
set -gx BIN_HOME "$HOME/.local/bin"
if not test -d "$BIN_HOME"
    mkdir -p "$BIN_HOME"
end
fish_add_path "$BIN_HOME"

# Set PATH to include user's private .local/scripts if it exists
set -gx SCRIPTS_HOME "$HOME/.local/scripts"
if not test -d "$SCRIPTS_HOME"
    mkdir -p "$SCRIPTS_HOME"
end
fish_add_path "$SCRIPTS_HOME"
