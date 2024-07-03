# init plugins in ~/.zsh/custom/plugins/zsh-* directory
for file in ~/.zsh/plugins.zsh.d/**/*-init.zsh; do
    source "$file"
done

