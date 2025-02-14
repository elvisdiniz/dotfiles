# Check if eza exists and set abbreviations
if test -x $(command -v eza)
    abbr ls eza
    abbr ll eza -lg
    abbr la eza -a
    abbr lla eza -lga
else
    abbr ll ls -lh
    abbr la ls -a
    abbr lla ls -lha
end

# Create a temporary directory and cd into it if mktemp exists
if test -x $(command -v mktemp)
    abbr cdtemp cd $(mktemp -d)
end

# Set alternative commands if the preferred ones are missing
if not test -x $(command -v vim)
    and test -x $(command -v vi)
    abbr vim vi
end

if not test -x $(command -v dig)
    and test -x $(command -v kdig)
    abbr dig kdig
end

if not test -x "$(command -v open)"
    and test -x "$(command -v xdg-open)"
    abbr open xdg-open
end

# WSL-specific configurations
if test -x "$(command -v notepad++.exe)"
    abbr npp notepad++.exe
end

if test -x "$(command -v ssh.exe)"
    abbr ssh ssh.exe
end

if test -x "$(command -v git.exe)"
    abbr git git.exe
end

# Create lazydocker abbreviation if available
if test -x "$(command -v lazydocker)"
    abbr lzd lazydocker
end
