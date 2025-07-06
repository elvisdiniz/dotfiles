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

# Function to install packages on Arch Linux
install_arch() {
    info "Installing packages for Arch Linux..."
    run_as_root pacman -Syu --noconfirm
    run_as_root pacman -S --noconfirm --needed \
        chezmoi starship eza bat curl git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh
}

# Function to install packages on Debian/Ubuntu
install_debian_ubuntu() {
    info "Installing packages for Debian/Ubuntu..."
    run_as_root apt-get update
    local packages="bat curl git vim fzf fd-find ripgrep neovim fish zsh"
    if [ "$ID" = "debian" ]; then
        if [ "$VERSION_ID" -ge 13 ]; then
            packages="$packages eza fastfetch btm"
        else
            packages="$packages exa"
        fi
    fi
    if [ "$ID" = "ubuntu" ]; then
        packages="$packages eza"
        if [ "$(echo "$VERSION_ID" | cut -d. -f1)" -ge 25 ]; then
            packages="$packages starship zoxide"
        fi
    fi
    run_as_root apt-get install -y $packages
    if [ "$(echo "$VERSION_ID" | cut -d. -f1)" -lt 25 ]; then
        if ! command_exists zoxide; then
            info "Installing zoxide..."
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        fi
    fi
}

# Function to install packages on Alpine Linux
install_alpine() {
    info "Installing packages for Alpine Linux..."
    run_as_root apk update
    run_as_root apk add chezmoi starship eza bat curl git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh
}

# Function to install packages on Fedora
install_fedora() {
    info "Installing packages for Fedora..."
    local packages="bat curl git vim fastfetch fzf fd-find ripgrep neovim fish zoxide zsh"
    if [ "$VERSION_ID" -lt 42 ]; then
        packages="$packages eza"
    fi
    run_as_root dnf install -y $packages
}

# Function to install packages on FreeBSD
install_freebsd() {
    info "Installing packages for FreeBSD..."
    run_as_root pkg update
    run_as_root pkg install -y chezmoi starship eza bat curl git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh
}

# Function to install packages on macOS
install_macos() {
    info "Installing packages for macOS..."
    if ! command_exists brew; then
        error "Homebrew is not installed. Please install it first."
        exit 1
    fi
    brew install chezmoi starship eza bat curl git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh
}

# Main installation logic
main() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')

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
