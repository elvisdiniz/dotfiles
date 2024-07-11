if [ -x "$(command -v vim)" ]; then
    [ "$(vim --clean -es +'exec "!echo" has("patch-9.1.0327")' +q)" -eq 0 ] && \
        export VIMINIT="
            if has('nvim')
                so ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua
            else
                set nocp
                so ${XDG_CONFIG_HOME:-$HOME/.config}/vim/vimrc
            endif
        "
fi