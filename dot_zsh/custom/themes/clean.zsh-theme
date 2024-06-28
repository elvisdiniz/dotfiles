# clean theme: inspired on dstufft theme

function is_ssh() {
  p=${1:-$PPID}
  read pid name x ppid y < <( cat /proc/$p/stat )
  # or: read pid name ppid < <(ps -o pid= -o comm= -o ppid= -p $p) 
  [[ "$name" =~ sshd ]] && { echo yes; return 0; }
  [ "$ppid" -le 1 ]     && { echo no; return 1; }
  is_ssh $ppid
}

function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    echo '○'
}

PROMPT='' # initialize prompt variable

if [ "$UID" != '1000' ]; then
    PROMPT+='%{$fg[magenta]%}%n%{$reset_color%} ' # add user if is not the default user
fi

if [ $(is_ssh) = 'yes' ]; then
    PROMPT+='at %{$fg[yellow]%}%m%{$reset_color%} ' # print host if is remote machine
elif [ -f /.dockerenv ]; then
    PROMPT+='at %{$fg[blue]%}%m%{$reset_color%} ' # print host if is remote machine
fi

PROMPT+='in %{$fg[green]%}%~%{$reset_color%}' # print cwd
PROMPT+='$(git_prompt_info)' # git info
PROMPT+='
%(?:%{$fg[green]%}%1{$(prompt_char)%} :%{$fg[red]%}%1{$(prompt_char)%}) ' # prompt char

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[yellow]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""
