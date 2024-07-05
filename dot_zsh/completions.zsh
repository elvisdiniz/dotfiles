for file in ~/.zsh/completions.zsh.d/**/*.completion.zsh; do
    source "$file"
done

# load completions from cache dir
for file in $HOME/.cache/zinit/completions/_*; do
    eval "$(/bin/cat $file)"
done
