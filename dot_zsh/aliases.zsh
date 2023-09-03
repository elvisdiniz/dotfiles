[[ ! -x "$(command -v exa)" ]] || alias ls="exa --icons --group-directories-first"
[[ ! -x "$(command -v bat)" ]] || alias bat="bat --style=auto"
[[ ! -x "$(command -v mktemp)" ]] || alias cdtemp="cd $(mktemp -d)"
