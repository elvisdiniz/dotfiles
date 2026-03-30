if status is-interactive
    set -g fish_key_bindings fish_vi_key_bindings

    bind -M insert \cf accept-autosuggestion

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

    if test -x "$(command -v atuin)"
        and atuin init fish 2>/dev/null >/dev/null
        atuin init fish | source
    end

    starship init fish | source
end
