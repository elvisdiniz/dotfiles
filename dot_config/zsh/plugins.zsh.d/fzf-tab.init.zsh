if [ -x "$(command -v fzf)" ]; then

if [ -x "$(command -v bat)" ]; then
  show_file_preview="bat -n --color=always --line-range :500"
else
  show_file_preview="cat -n"
fi

if [ -x "$(command -v eza)" ]; then
  show_dir_preview="eza --tree --color=always"
else
  show_dir_preview="ls --color=always"
fi

# Configure fzf-tab
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview "${show_dir_preview} \$realpath"
zstyle ':fzf-tab:complete:ssh:*' fzf-preview "kdig \$word"

zstyle ':fzf-tab:complete:*' fzf-preview "if [ ! -z \$realpath  ]; then if [ -d \$realpath ]; then ${show_dir_preview} \$realpath| head -200; elif [ -f \$realpath ];then ${show_file_preview} \$realpath ; else echo ''; fi; fi"

# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

fi