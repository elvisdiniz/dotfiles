for file in $ZDOTDIR/completions.zsh.d/**/*.completion.zsh; do
    source "$file"
done
