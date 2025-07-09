if status is-interactive
    set -U fish_greeting

    $SCRIPTS_HOME/install_starship.sh
    if test -x $BIN_HOME/starship
        eval "$(starship completions fish)"
    end

    if test -x "$(command -v zoxide)"
        zoxide init --cmd cd fish | source
    end

    if test -x "$(command -v fzf)"
        and fzf --fish 2>/dev/null >/dev/null
        fzf --fish | source
    end

    starship init fish | source
end
