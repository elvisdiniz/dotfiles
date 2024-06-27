function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    echo '○'
}

PROMPT='%{$fg[magenta]%}%n%{$reset_color%} ' # user

if [ -n "$SSH_CLIENT" ] || [ -f /.dockerenv ]; then
    PROMPT+='at %{$fg[yellow]%}%m%{$reset_color%} ' # print host if is remote machine
fi

PROMPT+='in %{$fg[green]%}%~%{$reset_color%}$(git_prompt_info)'
PROMPT+='
%(?:%{$fg[green]%}%1{$(prompt_char)%} :%{$fg[red]%}%1{$(prompt_char)%}) ' # prompt char

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""
