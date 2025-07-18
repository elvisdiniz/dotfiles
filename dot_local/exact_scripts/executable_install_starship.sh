#!/usr/bin/env sh

# check if starship is available on /usr/bin. If not, install on $BIN_HOME
if [ -x "/usr/bin/starship" ] || [ -x "/usr/local/bin/starship" ] || [ -x "/home/linuxbrew/.linuxbrew/bin/starship" ]; then
    [ -x "$BIN_HOME/starship" ] && rm "$BIN_HOME/starship"
else
    # if is inside a lxc container, download custom starship version
    if [ "$(cat /var/run/systemd/container 2>/dev/null)" = "lxc" ] && [ ! -x "$BIN_HOME/starship" ]; then
        cd $BIN_HOME
        wget -q https://github.com/elvisdiniz/starship/releases/download/v1.23.0-custom/starship-x86_64-unknown-linux-gnu.tar.gz
        tar xvf starship-x86_64-unknown-linux-gnu.tar.gz >/dev/null 2>&1
        rm starship-x86_64-unknown-linux-gnu.tar.gz
    else
        [ -x "$BIN_HOME/starship" ] || curl -sS https://starship.rs/install.sh | sh -s -- -b $BIN_HOME -y
    fi
fi
