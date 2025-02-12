if status is-interactive
  set -U fish_greeting

  # Commands to run in interactive sessions can go here
  $SCRIPTS_HOME/install_chezmoi.sh
  if test -x $BIN_HOME/chezmoi
    eval "$(chezmoi completion fish)"
  end

  $SCRIPTS_HOME/install_starship.sh
  if test -x $BIN_HOME/starship
    eval "$(starship completions fish)"
  end

  if test -x "$(command -v zoxide)"
    zoxide init --cmd cd fish | source
  end

  starship init fish | source
end
