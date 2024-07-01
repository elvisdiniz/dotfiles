# init plugins in ~/.zsh/custom/plugins/zsh-* directory
for file in ~/.zsh/custom/plugins/zsh-*/*-init.zsh; do
    source "$file"
done

