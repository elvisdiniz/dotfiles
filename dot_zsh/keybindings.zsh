bindkey '^ ' autosuggest-accept

# Set up fzf key bindings and fuzzy completion
[[ ! -x "$(command -v fzf)" ]] || source <(fzf --zsh)

