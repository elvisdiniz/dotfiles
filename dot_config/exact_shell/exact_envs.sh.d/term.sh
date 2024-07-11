# fallback to xterm-256color or xterm if $TERM is no available
if ! infocmp $TERM 2> /dev/null > /dev/null; then
    if infocmp xterm-256color 2> /dev/null > /dev/null; then
        export TERM=xterm-256color
    else
        export TERM=xterm
    fi
fi