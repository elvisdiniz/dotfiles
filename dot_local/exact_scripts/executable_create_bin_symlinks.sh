#!/usr/bin/env sh

[ -x "$(command -v fdfind)" ] && [ ! -L $HOME/.local/bin/fd ] && ln -sf "$(command -v fdfind)" $HOME/.local/bin/fd
[ ! -x "$(command -v fdfind)" ] && [ -L $HOME/.local/bin/fd ] && rm $HOME/.local/bin/fd

[ -x "$(command -v batcat)" ] && [ ! -L $HOME/.local/bin/bat ] && ln -sf "$(command -v batcat)" $HOME/.local/bin/bat
[ ! -x "$(command -v batcat)" ] && [ -L $HOME/.local/bin/bat ] && rm $HOME/.local/bin/bat

[ -x "$(command -v exa)" ] && [ ! -x "$(command -v eza)" ] && [ ! -L $HOME/.local/bin/eza ] && ln -sf "$(command -v exa)" $HOME/.local/bin/eza
[ ! -x "$(command -v exa)" ] && [ -L $HOME/.local/bin/eza ] && rm $HOME/.local/bin/eza

if [ -x "/usr/bin/chezmoi" ] || [ -x "/usr/local/bin/chezmoi" ] || [ -x "/home/linuxbrew/.linuxbrew/bin/chezmoi" ]; then
    [ -x "$HOME/.local/bin/chezmoi" ] && rm "$HOME/.local/bin/chezmoi"
fi

if [ -x "/usr/bin/zoxide" ] || [ -x "/usr/local/bin/zoxide" ] || [ -x "/home/linuxbrew/.linuxbrew/bin/zoxide" ]; then
    [ -x "$HOME/.local/bin/zoxide" ] && rm "$HOME/.local/bin/zoxide"
fi
