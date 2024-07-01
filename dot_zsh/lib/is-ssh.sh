# clean theme: inspired on dstufft theme

function is_ssh() {
  p=${1:-$PPID}
  read pid name x ppid y < <( cat /proc/$p/stat )
  # or: read pid name ppid < <(ps -o pid= -o comm= -o ppid= -p $p) 
  [[ "$name" =~ sshd ]] && { echo yes; return 0; }
  [ "$ppid" -le 1 ]     && { echo no; return 1; }
  is_ssh $ppid
}

export IS_SSH=$(is_ssh)
