for file in ${SHELL_CONFIG_HOME}/functions.sh.d/**/*.sh; do
    source "$file"
done

