# source .config/shell/*.sh files
export SHELL_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
[ -f "${SHELL_CONFIG_HOME}/paths.sh" ] && source "${SHELL_CONFIG_HOME}/paths.sh"
[ -f "${SHELL_CONFIG_HOME}/envs.sh" ] && source "${SHELL_CONFIG_HOME}/envs.sh"
for file in ${SHELL_CONFIG_HOME}/init.sh.d/*.sh; do
    source "$file"
done
[ -f "${SHELL_CONFIG_HOME}/aliases.sh" ] && source "${SHELL_CONFIG_HOME}/aliases.sh"