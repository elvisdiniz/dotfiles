#!/bin/sh

p=${1:-$PPID}

[ "$p" -eq 0 ] && exit 1
read pid ppid name < <(ps ax -o pid= -o ppid= -o comm= | /bin/grep -E -i "^\s*$p\s")
[[ "$name" =~ sshd ]] && exit 0
[ "$ppid" -le 1 ] && exit 1
is_ssh.sh $ppid
