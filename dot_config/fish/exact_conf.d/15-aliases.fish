# Check if eza exists and set aliases
if command -v eza > /dev/null
    alias ls="eza"
    alias ll="eza -lg"
    alias la="eza -a"
    alias lla="eza -lga"
else
    alias ll="ls -lh"
    alias la="ls -a"
    alias lla="ls -lha"
end

# Create a temporary directory and cd into it if mktemp exists
if command -v mktemp > /dev/null
    alias cdtemp="cd (mktemp -d)"
end

# Set alternative commands if the preferred ones are missing
if not command -v vim > /dev/null; and command -v vi > /dev/null
    alias vim="vi"
end

if not command -v dig > /dev/null; and command -v kdig > /dev/null
    alias dig="kdig"
end

if not command -v open > /dev/null; and command -v xdg-open > /dev/null
    alias open="xdg-open"
end

# WSL-specific configurations
if command -v notepad++.exe > /dev/null
    alias npp="notepad++.exe"
end

if command -v ssh.exe > /dev/null
    alias ssh="ssh.exe"
end

if command -v git.exe > /dev/null
    alias git="git.exe"
end

# Create lazydocker alias if available
if command -v lazydocker > /dev/null
    alias lzd="lazydocker"
end

