function is_ssh() {
  p=${1:-$PPID}
  [ "$p" -eq 0 ]     && { echo no; return 1; }
  read pid ppid name < <(ps ax -o pid= -o ppid= -o comm= | /bin/grep -E -i "^\s*$p\s")
  [[ "$name" =~ sshd ]] && { echo yes; return 0; }
  [ "$ppid" -le 1 ]     && { echo no; return 1; }
  is_ssh $ppid
}

