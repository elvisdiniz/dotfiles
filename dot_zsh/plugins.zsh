# init plugins in ~/.zsh/custom/plugins/zsh-* directory
for file in $(dirname $0)/plugins.zsh.d/**/*.init.zsh; do
    source "$file"
done

