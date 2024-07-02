# clean theme: inspired on dstufft theme

function is_ssh() {
  p=${1:-$PPID}
  [[ "$p" -eq 0 ]] || echo no; return 1
  read pid ppid name < <(ps -o pid= -o ppid= -o comm= -p $p) 
  [[ "$name" =~ sshd ]] && { echo yes; return 0; }
  [ "$ppid" -le 1 ]     && { echo no; return 1; }
  is_ssh $ppid
}

if [[ -z $SSH_CONNECTION && $(is_ssh) == "yes" ]]; then
  export SSH_CONNECTION=$(is_ssh)
fi
