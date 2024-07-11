for file in ${SHELL_CONFIG_HOME}/envs.sh.d/*.sh; do
    source "$file"
done
