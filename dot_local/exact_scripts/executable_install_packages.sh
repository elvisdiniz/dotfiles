#!/bin/sh

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
            run_as_root apt-get install -y gpg
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
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | run_as_root gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    fi
    if [ ! -f /etc/apt/sources.list.d/gierens.list ]; then
        info "Creating eza repository list file..."
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | run_as_root tee /etc/apt/sources.list.d/gierens.list
    fi
    run_as_root chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    run_as_root apt update
    info "Added eza repository and updated package list."
}

# Function to install the latest version of chezmoi from GitHub releases
install_chezmoi() {
    info "Installing the latest version of chezmoi..."
    if ! command_exists jq; then
        info "jq is not installed. Installing it now..."
        case "$ID" in
        "debian" | "ubuntu")
            run_as_root apt-get install -y jq
            ;;
        "fedora")
            run_as_root dnf install -y jq
            ;;
        *)
            error "Unsupported Linux distribution for jq installation: $ID"
            exit 1
            ;;
        esac
    fi

    local latest_version=$(curl -s "https://api.github.com/repos/twpayne/chezmoi/releases/latest" | jq -r '.tag_name' | sed 's/v//')
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
    wget "$download_url" -O "chezmoi.${file_ext}"

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

# Function to install the latest version of zoxide from GitHub releases
install_zoxide() {
    info "Installing the latest version of zoxide..."
    if ! command_exists jq; then
        info "jq is not installed. Installing it now..."
        case "$ID" in
        "debian" | "ubuntu")
            run_as_root apt-get install -y jq
            ;;
        *)
            error "Unsupported Linux distribution for jq installation: $ID"
            exit 1
            ;;
        esac
    fi

    local latest_version=$(curl -s "https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest" | jq -r '.tag_name' | sed 's/v//')
    local machine=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    local download_url=""
    local file_ext=""

    case "$ID" in
    "debian" | "ubuntu")
        file_ext="deb"
        download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${latest_version}/zoxide_${latest_version}-1_${machine}.${file_ext}"
        ;;
    *)
        error "Unsupported Linux distribution for zoxide installation: $ID"
        exit 1
        ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading zoxide from ${download_url}"
    wget "$download_url" -O "zoxide.${file_ext}"

    case "$ID" in
    "debian" | "ubuntu")
        run_as_root dpkg -i "zoxide.${file_ext}"
        ;;
    esac

    cd -
    rm -rf "$temp_dir"
}

# Function to install packages on Arch Linux
install_arch() {
    info "Installing packages for Arch Linux..."
    run_as_root pacman -Syu --noconfirm
    run_as_root pacman -S --noconfirm --needed \
        chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux
}

# Function to install packages on Debian/Ubuntu
install_debian_ubuntu() {
    info "Installing packages for Debian/Ubuntu..."
    add_eza_apt_repository
    run_as_root apt-get update
    local packages="bat curl eza wget git vim fzf fd-find ripgrep neovim fish zsh tmux"
    if [ "$ID" = "debian" ]; then
        if [ "$VERSION_ID" -ge 13 ]; then
            packages="$packages fastfetch btm zoxide starship"
        else
            install_zoxide
        fi
    fi
    if [ "$ID" = "ubuntu" ]; then
        packages="$packages zoxide btm"
        if [ "$(echo "$VERSION_ID" | cut -d. -f1)" -ge 25 ]; then
            packages="$packages starship fastfetch"
        fi
    fi
    run_as_root apt-get install -y $packages
    install_chezmoi
}

# Function to install packages on Alpine Linux
install_alpine() {
    info "Installing packages for Alpine Linux..."
    run_as_root apk update
    run_as_root apk add chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux
}

# Function to install packages on Fedora
install_fedora() {
    info "Installing packages for Fedora..."
    local packages="bat curl wget git vim fastfetch fzf fd-find ripgrep neovim fish zoxide zsh tmux"
    if [ "$VERSION_ID" -lt 42 ]; then
        packages="$packages eza"
    fi
    run_as_root dnf install -y $packages
    install_chezmoi
}

# Function to install packages on FreeBSD
install_freebsd() {
    info "Installing packages for FreeBSD..."
    run_as_root pkg update
    run_as_root pkg install -y chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux
}

# Function to install packages on macOS
install_macos() {
    info "Installing packages for macOS..."
    if ! command_exists brew; then
        error "Homebrew is not installed. Please install it first."
        exit 1
    fi
    brew install chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux
}

# Main installation logic
main() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    machine=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')

    if ! command_exists wget; then
        error "wget is not installed. Please install it first."
        exit 1
    fi

    if ! command_exists curl; then
        error "curl is not installed. Please install it first."
        exit 1
    fi

    case "$os" in
    "linux")
        if [ -f /etc/os-release ]; then
            . /etc/os-release
        else
            error "Cannot determine Linux distribution because /etc/os-release is not present."
            exit 1
        fi

        case "$ID" in
        "arch")
            install_arch
            ;;
        "debian" | "ubuntu")
            install_debian_ubuntu
            ;;
        "alpine")
            install_alpine
            ;;
        "fedora")
            install_fedora
            ;;
        *)
            error "Unsupported Linux distribution: $ID"
            exit 1
            ;;
        esac
        ;;
    "darwin")
        install_macos
        ;;
    "freebsd")
        install_freebsd
        ;;
    *)
        error "Unsupported operating system: $os"
        exit 1
        ;;
    esac
    info "Package installation complete."
}

main
