#!/usr/bin/env sh

set -e
set -u

# Function to print info messages
info() {
    printf "\033[1;34m%s\033[0m\n" "$1"
}

# Function to print error messages
error() {
    printf "\033[1;31m%s\033[0m\n" "$1" >&2
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Helper to run commands as root or with sudo if not root
run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

add_eza_apt_repository() {
    if ! command_exists gpg; then
        info "gpg is not installed. Installing it now..."
        case "$ID" in
        "debian" | "ubuntu")
            run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y gpg
            ;;
        *)
            error "Unsupported Linux distribution for gpg installation: $ID"
            exit 1
            ;;
        esac
    fi

    run_as_root mkdir -p /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/gierens.gpg ]; then
        info "Downloading gierens.gpg keyring..."
        curl -sL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | run_as_root gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    fi
    if [ ! -f /etc/apt/sources.list.d/gierens.list ]; then
        info "Creating eza repository list file..."
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | run_as_root tee /etc/apt/sources.list.d/gierens.list
    fi
    run_as_root chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    run_as_root apt update
    info "Added eza repository and updated package list."
}

install_package() {
    local package_name="$1"
    if ! command_exists $package_name; then
        info "$package_name is not installed. Installing it now..."
        case "$ID" in
        "debian" | "ubuntu")
            run_as_root apt-get install -y $package_name
            ;;
        "fedora")
            run_as_root dnf install -y $package_name
            ;;
        "opensuse-tumbleweed" | "opensuse-leap")
            run_as_root zypper install -y $package_name
            ;;
        "alpine")
            run_as_root apk add $package_name
            ;;
        *)
            error "Unsupported Linux distribution for $package_name installation: $ID"
            exit 1
            ;;
        esac
    fi
}

# Function to install the latest version of chezmoi from GitHub releases
install_chezmoi() {
    install_package jq

    info "Checking for the latest version of chezmoi..."
    local latest_version=$(curl -s "https://api.github.com/repos/twpayne/chezmoi/releases/latest" | jq -r '.tag_name' | sed 's/v//')

    if command_exists chezmoi; then
        local current_version=$(chezmoi --version | cut -d ' ' -f 3 | sed 's/v//;s/,//')
        if [ "$current_version" = "$latest_version" ]; then
            info "chezmoi is already up to date (version $current_version)."
            return
        else
            info "A new version of chezmoi is available: $latest_version (you have $current_version)."
        fi
    fi

    info "Installing the latest version of chezmoi..."

    local machine=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    local download_url=""
    local file_ext=""

    case "$ID" in
    "debian" | "ubuntu")
        file_ext="deb"
        download_url="https://github.com/twpayne/chezmoi/releases/download/v${latest_version}/chezmoi_${latest_version}_linux_${machine}.${file_ext}"
        ;;
    "fedora")
        file_ext="rpm"
        local arch=$(uname -m)
        download_url="https://github.com/twpayne/chezmoi/releases/download/v${latest_version}/chezmoi-${latest_version}-${arch}.rpm"
        ;;
    *)
        error "Unsupported Linux distribution for chezmoi installation: $ID"
        exit 1
        ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading chezmoi from ${download_url}"
    curl -L "$download_url" -o "chezmoi.${file_ext}"

    case "$ID" in
    "debian" | "ubuntu")
        run_as_root dpkg -i "chezmoi.${file_ext}"
        ;;
    "fedora")
        run_as_root rpm -i "chezmoi.${file_ext}"
        ;;
    esac

    cd -
    rm -rf "$temp_dir"
}

# Function to install the latest version of fastfetch from GitHub releases
install_fastfetch() {
    install_package jq

    info "Checking for the latest version of fastfetch..."
    local latest_version=$(curl -s "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest" | jq -r '.tag_name')

    if command_exists fastfetch; then
        local current_version=$(fastfetch --version | cut -d ' ' -f 2 | cut -d '-' -f 1)
        if [ "$current_version" = "$latest_version" ]; then
            info "fastfetch is already up to date (version $current_version)."
            return
        else
            info "A new version of fastfetch is available: $latest_version (you have $current_version)."
        fi
    fi

    info "Installing the latest version of fastfetch..."

    local machine=$(uname -m | sed 's/x86_64/amd64/;s/arm64/aarch64/')
    local download_url=""
    local file_ext=""

    case "$ID" in
    "debian" | "ubuntu")
        file_ext="deb"
        download_url="https://github.com/fastfetch-cli/fastfetch/releases/download/${latest_version}/fastfetch-linux-${machine}.${file_ext}"
        ;;
    *)
        error "Unsupported Linux distribution for fastfetch installation: $ID"
        exit 1
        ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading fastfetch from ${download_url}"
    curl -L "$download_url" -o "fastfetch.${file_ext}"

    case "$ID" in
    "debian" | "ubuntu")
        run_as_root dpkg -i "fastfetch.${file_ext}"
        ;;
    esac

    cd -
    rm -rf "$temp_dir"
}

# Function to install the latest version of zoxide from GitHub releases
install_zoxide() {
    install_package jq
    install_package tar
    install_package gzip

    info "Checking for the latest version of zoxide..."
    local latest_version=$(curl -s "https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest" | jq -r '.tag_name' | sed 's/v//')

    if command_exists zoxide; then
        local current_version=$(zoxide --version | cut -d ' ' -f 2)
        if [ "$current_version" = "$latest_version" ]; then
            info "zoxide is already up to date (version $current_version)."
            return
        else
            info "A new version of zoxide is available: $latest_version (you have $current_version)."
        fi
    fi

    info "Installing the latest version of zoxide..."

    local machine
    machine=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    local download_url=""
    local file_ext=""

    case "$ID" in
    "debian" | "ubuntu")
        file_ext="deb"
        download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${latest_version}/zoxide_${latest_version}-1_${machine}.${file_ext}"
        ;;
    "opensuse-leap")
        file_ext="tar.gz"
        local arch
        arch=$(uname -m)
        download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${latest_version}/zoxide-${latest_version}-${arch}-unknown-linux-musl.${file_ext}"
        ;;
    *)
        error "Unsupported Linux distribution for zoxide installation: $ID"
        exit 1
        ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading zoxide from ${download_url}"
    curl -L "$download_url" -o "zoxide.${file_ext}"

    case "$ID" in
    "debian" | "ubuntu")
        run_as_root dpkg -i "zoxide.${file_ext}"
        ;;
    "opensuse-leap")
        info "Installing Extracting zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir /usr/local/bin --man-dir /usr/local/man
        info "zoxide installed successfully."
        ;;
    esac

    cd -
    rm -rf "$temp_dir"
}

install_bottom() {
    install_package jq

    info "Checking for the latest version of bottom..."
    local latest_version=$(curl -s "https://api.github.com/repos/ClementTsang/bottom/releases/latest" | jq -r '.tag_name')

    if command_exists btm; then
        local current_version=$(btm --version | cut -d ' ' -f 2)
        if [ "$current_version" = "$latest_version" ]; then
            info "bottom is already up to date (version $current_version)."
            return
        else
            info "A new version of bottom is available: $latest_version (you have $current_version)."
        fi
    fi

    info "Installing the latest version of bottom..."

    local machine=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    local download_url=""
    local file_ext=""

    case "$ID" in
    "debian" | "ubuntu")
        file_ext="deb"
        download_url="https://github.com/ClementTsang/bottom/releases/download/${latest_version}/bottom_${latest_version}-1_${machine}.${file_ext}"
        ;;
    *)
        error "Unsupported Linux distribution for bottom installation: $ID"
        exit 1
        ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading bottom from ${download_url}"
    curl -L "$download_url" -o "bottom.${file_ext}"

    case "$ID" in
    "debian" | "ubuntu")
        run_as_root dpkg -i "bottom.${file_ext}"
        ;;
    esac

    cd -
    rm -rf "$temp_dir"
}

install_eza() {
    install_package jq

    info "Checking for the latest version of eza..."
    local latest_version=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" | jq -r '.tag_name' | sed 's/v//')

    if command_exists eza; then
        local current_version=$(eza --version | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+' | cut -d ' ' -f 1 | sed 's/v//')
        if [ "$current_version" = "$latest_version" ]; then
            info "eza is already up to date (version $current_version)."
            return
        else
            info "A new version of eza is available: $latest_version (you have $current_version)."
        fi
    fi

    info "Installing the latest version of eza..."

    local machine=$(uname -m | sed 's/amd64/x86_64/;s/arm64/aarch64/')
    local download_url=""
    local file_ext=""

    file_ext="tar.gz"
    bin_download_url="https://github.com/eza-community/eza/releases/download/v${latest_version}/eza_${machine}-unknown-linux-gnu.${file_ext}"
    completions_download_url="https://github.com/eza-community/eza/releases/download/v${latest_version}/completions-${latest_version}.${file_ext}"
    man_download_url="https://github.com/eza-community/eza/releases/download/v${latest_version}/man-${latest_version}.${file_ext}"

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading eza from ${bin_download_url}"
    curl -L "$bin_download_url" -o "eza.${file_ext}"
    curl -L "$completions_download_url" -o "completions.${file_ext}"
    curl -L "$man_download_url" -o "man.${file_ext}"

    info "Extracting eza..."

    mkdir -p /usr/local/bin
    run_as_root tar -xzf "eza.${file_ext}" --directory=/usr/local/bin
    chmod +x /usr/local/bin/eza
    mkdir completions
    tar -xzf "completions.${file_ext}" --directory=completions
    run_as_root mkdir -p /usr/local/share/zsh/site-functions
    run_as_root mkdir -p /usr/local/share/bash-completion/completions
    run_as_root mkdir -p /usr/share/fish/vendor_completions.d
    run_as_root mv "$temp_dir/completions/target/completions-${latest_version}/_eza" /usr/local/share/zsh/site-functions/_eza
    run_as_root mv "$temp_dir/completions/target/completions-${latest_version}/eza" /usr/local/share/bash-completion/completions/eza
    run_as_root mv "$temp_dir/completions/target/completions-${latest_version}/eza.fish" /usr/share/fish/vendor_completions.d/eza.fish
    mkdir man
    tar -xzf "man.${file_ext}" --directory=man
    mkdir -p /usr/local/share/man/man1
    run_as_root mv "$temp_dir/man/target/man-${latest_version}/eza.1" /usr/local/share/man/man1/eza.1
    mkdir -p /usr/local/share/man/man5
    run_as_root mv "$temp_dir/man/target/man-${latest_version}/eza_colors.5" /usr/local/share/man/man5/eza_colors.5
    run_as_root mv "$temp_dir/man/target/man-${latest_version}/eza_colors-explanation.5" /usr/local/share/man/man5/eza_colors-explanation.5

    info "eza installed successfully."

    cd -
    rm -rf "$temp_dir"
}

# Function to install the latest version of Neovim from GitHub releases
install_neovim() {
    install_package jq
    install_package rsync

    info "Checking for the latest version of Neovim..."
    local latest_tag=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | jq -r '.tag_name')
    if [ -z "$latest_tag" ] || [ "$latest_tag" = "null" ]; then
        error "Could not fetch latest Neovim version tag from GitHub."
        return 1
    fi
    local latest_version=$(echo "$latest_tag" | sed 's/v//')

    if command_exists nvim; then
        # NVIM v0.9.5 -> 0.9.5
        local current_version=$(nvim --version | head -n 1 | cut -d ' ' -f 2 | sed 's/v//')
        if [ "$current_version" = "$latest_version" ]; then
            info "Neovim is already up to date (version $current_version)."
            return
        else
            info "A new version of Neovim is available: $latest_version (you have $current_version)."
        fi
    fi

    info "Installing the latest version of Neovim..."

    local machine=$(uname -m | sed 's/amd64/x86_64/;s/aarch64/arm64/')
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    case "$ID" in
    "debian" | "ubuntu")
        if [ "$machine" = "x86_64" ] || [ "$machine" = "arm64" ]; then
            local download_url="https://github.com/neovim/neovim/releases/download/${latest_tag}/nvim-linux-${machine}.tar.gz"
            info "Downloading Neovim from ${download_url}"
            curl -L "$download_url" -o "neovim.tar.gz"
            info "Extracting Neovim..."
            tar -xzf "neovim.tar.gz"
            info "Uninstalling any existing Neovim installation..."
            run_as_root apt remove -y neovim || true
            info "Installing Neovim to /usr/local..."
            # Using rsync to merge directories
            run_as_root rsync -a --chown=root:root nvim-linux-${machine}/ /usr/local/
            info "Neovim installed successfully."
        else
            error "Unsupported machine architecture for Neovim installation: $machine"
        fi
        ;;
    *)
        error "Unsupported Linux distribution for Neovim installation: $ID"
        ;;
    esac

    cd -
    rm -rf "$temp_dir"
}

# Function to install the latest version of fzf from GitHub releases
install_fzf() {
    install_package jq
    install_package tar
    install_package gzip

    info "Checking for the latest version of fzf..."
    local latest_version=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | jq -r '.tag_name' | sed 's/v//')

    if command_exists fzf; then
        # fzf 0.48.1 (e5f84ea) -> 0.48.1
        local current_version=$(fzf --version | cut -d ' ' -f 1)
        if [ "$current_version" = "$latest_version" ]; then
            info "fzf is already up to date (version $current_version)."
            return
        else
            info "A new version of fzf is available: $latest_version (you have $current_version)."
        fi
    fi

    # If Debian or Ubuntu, remove the existing fzf package to avoid conflicts with the new installation
    if [ "$ID" = "debian" ] || [ "$ID" = "ubuntu" ]; then
        if dpkg -l | grep -q fzf; then
            info "Removing existing fzf package to avoid conflicts..."
            run_as_root apt-get remove -y fzf
        fi
    fi

    info "Installing the latest version of fzf..."

    local machine
    machine=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    local bin_download_url=""
    local file_ext="tar.gz"

    bin_download_url="https://github.com/junegunn/fzf/releases/download/v${latest_version}/fzf-${latest_version}-linux_${machine}.${file_ext}"

    src_download_url="https://github.com/junegunn/fzf/archive/v${latest_version}.tar.gz"

    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    info "Downloading fzf from ${bin_download_url}"
    curl -L "$bin_download_url" -o "fzf.${file_ext}"

    info "Downloading fzf source from ${src_download_url}"
    curl -L "$src_download_url" -o "fzf-src.${file_ext}"

    info "Extracting fzf..."
    tar -xzf "fzf.${file_ext}"

    info "Extracting fzf source..."
    tar -xzf "fzf-src.${file_ext}"

    info "Installing fzf binary..."
    run_as_root install -m 0755 fzf /usr/local/bin/fzf

    info "Installing fzf-tmux script..."
    run_as_root install -m 0755 fzf-${latest_version}/bin/fzf-tmux /usr/local/bin/fzf-tmux

    info "Installing fzf man page..."
    run_as_root install -m 0644 -D fzf-${latest_version}/man/man1/fzf.1 /usr/local/share/man/man1/fzf.1

    info "Installing fzf shell completions..."
    run_as_root install -m 0644 -D fzf-${latest_version}/shell/completion.bash /usr/local/share/bash-completion/completions/fzf
    run_as_root install -m 0644 -D fzf-${latest_version}/shell/completion.zsh /usr/local/share/zsh/site-functions/_fzf
    run_as_root install -m 0644 -D fzf-${latest_version}/shell/completion.fish /usr/share/fish/vendor_completions.d/fzf.fish

    info "Installing fzf key-bindings..."
    run_as_root install -m 0644 -D fzf-${latest_version}/shell/key-bindings.bash /usr/local/share/bash-completion/completions/fzf-key-bindings
    run_as_root install -m 0644 -D fzf-${latest_version}/shell/key-bindings.zsh /usr/local/share/zsh/site-functions/_fzf-key-bindings
    run_as_root install -m 0644 -D fzf-${latest_version}/shell/key-bindings.fish /usr/share/fish/vendor_completions.d/fzf-key-bindings.fish

    info "fzf installed successfully."

    cd -
    rm -rf "$temp_dir"
}

install_starship() {
    install_package curl

    # Check if starship is already installed and up to date
    info "Checking for the latest version of starship..."
    local latest_version=$(curl -s "https://api.github.com/repos/starship/starship/releases/latest" | jq -r '.tag_name' | sed 's/v//')
    if command_exists starship; then
        local current_version=$(starship --version | cut -d ' ' -f 2 | head -n 1)
        if [ "$current_version" = "$latest_version" ]; then
            info "starship is already up to date (version $current_version)."
            return
        else
            info "A new version of starship is available: $latest_version (you have $current_version)."
        fi
    fi

    info "Installing the latest version of starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir /usr/local/bin
}

# Function to install packages on Arch Linux
setup_arch() {
    info "Installing packages for Arch Linux..."
    run_as_root pacman -Syu --noconfirm
    run_as_root pacman -S --noconfirm --needed \
        gcc chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux sudo
}

# Function to install packages on Debian/Ubuntu
setup_debian_ubuntu() {
    info "Installing packages for Debian/Ubuntu..."
    run_as_root apt-get update
    local packages="gcc bat curl eza wget git vim fd-find ripgrep fish zsh tmux sudo"
    if [ "$ID" = "debian" ]; then
        if [ "$VERSION_ID" -ge 13 ]; then
            packages="$packages fastfetch btm zoxide starship"
        else
            add_eza_apt_repository
            install_zoxide
            install_fastfetch
            install_bottom
            install_starship
        fi
    fi
    if [ "$ID" = "ubuntu" ]; then
        packages="$packages zoxide btm"
        if [ "$(echo "$VERSION_ID" | cut -d. -f1)" -ge 25 ]; then
            packages="$packages starship fastfetch"
        else
            install_fastfetch
            install_starship
        fi
    fi
    run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y $packages
    install_chezmoi
    install_neovim
    install_fzf
}

# Function to install packages on Alpine Linux
setup_alpine() {
    info "Installing packages for Alpine Linux..."
    run_as_root apk update
    run_as_root apk add build-base tree-sitter-cli bash chezmoi starship eza bat curl wget git vim fastfetch fzf fzf-tmux fzf-zsh-plugin fzf-fish-plugin fzf-bash-plugin fd ripgrep neovim bottom fish zoxide zsh tmux sudo
}

# Function to install packages on Fedora
setup_fedora() {
    info "Installing packages for Fedora..."
    run_as_root dnf copr enable -y atim/starship
    local packages="starship bat curl wget gcc git vim fastfetch fzf fd-find ripgrep neovim fish zoxide zsh tmux procps-ng"
    if [ "$VERSION_ID" -lt 42 ]; then
        packages="$packages eza"
    else
        install_eza
    fi
    run_as_root dnf install -y $packages
    install_chezmoi
}

# Function to install packages on openSUSE
setup_opensuse() {
    info "Installing packages for openSUSE..."
    local packages="bash chezmoi starship gcc eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zsh tmux sudo"
    if [ "$ID" = "opensuse-tumbleweed" ]; then
        packages="$packages zoxide"
    fi
    if [ "$ID" = "opensuse-leap" ]; then
        install_zoxide
    fi
    run_as_root zypper install -y --no-recommends $packages
}

# Function to install packages on FreeBSD
setup_freebsd() {
    info "Installing packages for FreeBSD..."
    run_as_root pkg update
    run_as_root pkg install -y gcc tree-sitter-cli chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux sudo
}

# Function to install packages on macOS
setup_macos() {
    info "Installing packages for macOS..."
    if ! command_exists brew; then
        error "Homebrew is not installed. Please install it first."
        exit 1
    fi
    brew install chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux
}

# Function to set up a new user
setup_user() {
    local username=$1
    local os_type=$2
    local linux_distro_id=$3

    info "Setting up user: $username"

    if [ "$os_type" = "darwin" ]; then
        error "User setup is not supported on macOS."
        return
    fi

    local admin_group=""

    # Determine admin group and commands based on OS
    case "$os_type" in
    "linux")
        admin_group="sudo"
        if [ "$linux_distro_id" = "alpine" ]; then
            admin_group="wheel"
        fi

        # Create admin group if it doesn't exist
        if ! getent group "$admin_group" >/dev/null; then
            info "Creating group '$admin_group'..."
            if [ "$linux_distro_id" = "alpine" ]; then
                run_as_root addgroup "$admin_group"
            else
                run_as_root groupadd "$admin_group"
            fi
        fi

        # Create user if it doesn't exist
        if ! id "$username" >/dev/null 2>&1; then
            info "Creating user '$username'..."
            if [ "$linux_distro_id" = "alpine" ]; then
                # -D: no password, -s: shell
                run_as_root adduser -D -s $(which zsh) "$username"
            else
                # -m: create home, -s: shell
                run_as_root useradd -m -s $(which zsh) "$username"
            fi
            info "User '$username' created."
        else
            info "User '$username' already exists."
        fi

        # Add user to admin group
        info "Adding user '$username' to group '$admin_group'..."
        if [ "$linux_distro_id" = "alpine" ]; then
            run_as_root addgroup "$username" "$admin_group"
        else
            run_as_root usermod -aG "$admin_group" "$username"
        fi
        ;;
    "freebsd")
        admin_group="wheel" # 'wheel' is the convention on FreeBSD

        # Ensure wheel group exists
        if ! pw group show "$admin_group" >/dev/null 2>&1; then
            info "Creating group '$admin_group'..."
            run_as_root pw groupadd "$admin_group"
        fi

        # Create user if it doesn't exist
        if ! id "$username" >/dev/null 2>&1; then
            info "Creating user '$username'..."
            # -m: create home, -s: shell
            run_as_root pw useradd "$username" -s $(which zsh) -m
            info "User '$username' created."
        else
            info "User '$username' already exists."
        fi

        # Add user to wheel group
        info "Adding user '$username' to group '$admin_group'..."
        run_as_root pw usermod "$username" -G "$admin_group"
        ;;
    *)
        error "User setup is not supported on this operating system: $os_type"
        return
        ;;
    esac

    # Set password for the user
    info "Please set a password for $username:"
    run_as_root passwd "$username"

    info "User $username setup complete."
}

# Function to apply dotfiles using chezmoi
apply_dotfiles() {
    local dotfiles_repo=$1
    info "Initializing and applying dotfiles from $dotfiles_repo..."
    if ! command_exists chezmoi; then
        error "chezmoi is not installed. Please install it first."
        exit 1
    fi
    chezmoi init --apply "$dotfiles_repo"
    info "Dotfiles applied successfully."
}

# Main installation logic
main() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local linux_distro_id=""
    if [ "$os" = "linux" ]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            linux_distro_id=$ID
        else
            error "Cannot determine Linux distribution because /etc/os-release is not present."
            exit 1
        fi
    fi

    local username=""
    local dotfiles_repo=""
    while [ "$#" -gt 0 ]; do
        case "$1" in
        -u | --user)
            if [ -z "${2:-}" ]; then
                error "Argument for $1 is missing"
                exit 1
            fi
            username="$2"
            shift 2
            ;;
        -d | --dotfiles)
            if [ -z "${2:-}" ]; then
                error "Argument for $1 is missing"
                exit 1
            fi
            dotfiles_repo="$2"
            shift 2
            ;;
        *)
            error "Unknown argument: $1"
            exit 1
            ;;
        esac
    done

    machine=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')

    if ! command_exists curl; then
        error "curl is not installed. Please install it first."
        exit 1
    fi

    case "$os" in
    "linux")
        case "$ID" in
        "arch")
            setup_arch
            ;;
        "debian" | "ubuntu")
            setup_debian_ubuntu
            ;;
        "alpine")
            setup_alpine
            ;;
        "fedora")
            setup_fedora
            ;;
        "opensuse-tumbleweed" | "opensuse-leap")
            setup_opensuse
            ;;
        *)
            error "Unsupported Linux distribution: $ID"
            exit 1
            ;;
        esac
        ;;
    "darwin")
        setup_macos
        ;;
    "freebsd")
        setup_freebsd
        ;;
    *)
        error "Unsupported operating system: $os"
        exit 1
        ;;
    esac
    info "Package installation complete."

    if [ -n "$username" ]; then
        setup_user "$username" "$os" "$linux_distro_id"
    fi

    if [ -n "$dotfiles_repo" ]; then
        apply_dotfiles "$dotfiles_repo"
    fi
}

main "$@"

