function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    echo '○'
}

PROMPT='' # initialize prompt variable

if [ "$DEFAULT_USER" != "$USER" ]; then
    PROMPT+='%{$fg[magenta]%}%n%{$reset_color%} ' # add user if is not the default user
fi

if [ -n "$SSH_CLIENT" ]; then
    PROMPT+='at %{$fg[yellow]%}%m%{$reset_color%} ' # print host if is remote machine
elif [ -f /.dockerenv ]; then
    PROMPT+='at %{$fg[blue]%}%m%{$reset_color%} ' # print host if is remote machine
fi

PROMPT+='in %{$fg[green]%}%~%{$reset_color%}$(git_prompt_info)'
PROMPT+='
%(?:%{$fg[green]%}%1{$(prompt_char)%} :%{$fg[red]%}%1{$(prompt_char)%}) ' # prompt char

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[yellow]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""
