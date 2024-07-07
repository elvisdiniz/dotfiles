# init plugins in $ZDOTDIR/custom/plugins/zsh-* directory
for file in $ZDOTDIR/plugins.zsh.d/**/*.init.zsh; do
    source "$file"
done
