#!/usr/bin/env sh

# check if starship is available on /usr/bin. If not, install on $BIN_HOME
if [ -x "/usr/bin/chezmoi" ] || [ -x "/usr/local/bin/chezmoi" ] || [ -x "/home/linuxbrew/.linuxbrew/bin/chezmoi" ]; then
    [ -x "$BIN_HOME/chezmoi" ] && rm "$BIN_HOME/chezmoi"
else
    [ -x "$BIN_HOME/chezmoi" ] || sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $BIN_HOME
fi