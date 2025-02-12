# set XDG paths if does not exists yet
if not set -q XDG_CONFIG_HOME
  set XDG_CONFIG_HOME "$HOME/.config"
end
if not set -q XDG_DATA_HOME
  set XDG_DATA_HOME "$HOME/.local/share"
end
if not set -q XDG_CACHE_HOME
  set XDG_CACHE_HOME "$HOME/.cache"
end
if not set -q XDG_SATE_HOME
  set XDG_STATE_HOME "$HOME/.local/state"
end

# acme.sh setup
if test -d ~/.acme.sh
  set -gx LE_WORKING_DIR "$HOME/.acme.sh"
  alias acme.sh="$LE_WORKING_DIR/acme.sh"
end

# ansible setup
set -gx ANSIBLE_HOME "$XDG_CONFIG_HOME/ansible"
set -gx ANSIBLE_CONFIG "$XDG_CONFIG_HOME/ansible/ansible.cfg"
set -gx ANSIBLE_GALAXY_CACHE_DIR "$XDG_CACHE_HOME/ansible/galaxy_cache"

# asdf setup
set -gx ASDF_DATA_DIR "$XDG_DATA_HOME/asdf"
if test -f "$ASDF_DATA_DIR/asdf.fish"
  set -gx ASDF_CONFIG_FILE "$XDG_CONFIG_HOME/asdf/asdfrc"
  source "$ASDF_DATA_DIR/asdf.fish"
end

# cargo/rust setup
if test -x "$(command -v cargo)"
  set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
  mkdir -p "$CARGO_HOME"
end

# dotnet setup
set -gx DOTNET_CLI_HOME "$XDG_DATA_HOME/dotnet"

# configure $EDITOR variable
if test -x "$(command -v nvim)"
    set -gx EDITOR nvim
else if test -x "$(command -v vim)"
    set -gx EDITOR vim
else if test -x "$(command -v vi)"
    set -gx EDITOR vi
else if test -x "$(command -v nano)"
    set -gx EDITOR nano
end

# eza setup
if test -x "$(command -v eza)"
  set -gx EZA_ICONS_AUTO 1
end

# golang setup
set -gx GOPATH "$XDG_DATA_HOME/go"
set -gx GOMODCACHE "$XDG_CACHE_HOME/go/mod"

# load Homebrew on Linux
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)
end

set -gx NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"
set -gx NPM_PREFIX_HOME "$XDG_DATA_HOME/npm"
set -gx NPM_CACHE_HOME "$XDG_CACHE_HOME/npm"
set -gx NPM_INIT_MODULE "$XDG_CONFIG_HOME/npm/config/npm-init.js"
set -gx NPM_LOGS_DIR "$XDG_STATE_HOME/npm/logs"
set -gx NVM_DIR "$XDG_DATA_HOME/nvm"

# nuget
set -gx NUGET_PACKAGES "$XDG_CACHE_HOME/NuGetPackages"

# nvidia/cuda
if test -z "$CUDA_CACHE_PATH"
  set -gx CUDA_CACHE_PATH "$XDG_CACHE_HOME/nv"
end

# python
set -gx PYTHON_HISTORY "$XDG_STATE_HOME/python/history"
set -gx PYTHONPYCACHEPREFIX "$XDG_CACHE_HOME/python"
set -gx PYTHONUSERBASE "$XDG_DATA_HOME/python"

if test -z "$SSH_CONNECTION"
    and is_ssh.sh
    set -gx SSH_CONNECTION yes
end

# fallback to xterm-256color or xterm if $TERM is no available
if test -x "$(command -v infocmp)"
  and not infocmp $TERM 2> /dev/null > /dev/null
  if infocmp xterm-256color 2> /dev/null > /dev/null
    set -gx TERM xterm-256color
  else
    set -gx TERM xterm
  end
end

if test -x "$(command -v vim)"
    if test "$(vim --clean -es +'exec "!echo" has("patch-9.1.0327")' +q)" -eq 0
        set -gx VIMINIT "
            if has('nvim')
                so $XDG_CONFIG_HOME/nvim/init.lua
            else
                set nocp
                so $XDG_CONFIG_HOME/vim/vimrc
            endif
        "
    end
end
