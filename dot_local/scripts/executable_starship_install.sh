#!/usr/bin/env sh

# check if starship is available on /usr/bin. If not, install on $BIN_HOME
if [ -x "/usr/bin/starship" ] || [ -x "/usr/local/bin/starship" ] || [ -x "/home/linuxbrew/.linuxbrew/bin/starship" ]; then
    [ -x "$BIN_HOME/starship" ] && rm "$BIN_HOME/starship"
else
    [ -x "$BIN_HOME/starship" ] || curl -sS https://starship.rs/install.sh | sh -s -- -b $BIN_HOME -y
fi