if [ -x "$(command -v nvim)" ]; then
    export EDITOR=nvim
elif [ -x "$(command -v vim)" ]; then
    export EDITOR=vim
elif [ -x "$(command -v vi)" ]; then
    export EDITOR=vi
elif [ -x "$(command -v nano)" ]; then
    export EDITOR=nano
fi