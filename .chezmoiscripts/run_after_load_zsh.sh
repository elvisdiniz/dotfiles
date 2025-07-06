#!/usr/bin/env sh

[ -x "$(command -v zsh)" ] && zsh -c "source $HOME/.zshenv; source $HOME/.config/zsh/.zshrc; exit"
