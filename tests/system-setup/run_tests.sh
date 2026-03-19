#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SETUP_SCRIPT="${SCRIPT_DIR}/../../dot_local/bin/executable_system-setup.sh"

# Ensure the setup script is executable
chmod +x "$SETUP_SCRIPT"

# Define test cases: image_name:distro_id:version_id (if needed for specific checks)
declare -A TEST_IMAGES
TEST_IMAGES=(
    ["archlinux/archlinux"]="arch::"
    ["debian:bookworm-slim"]="debian:12:" # Debian 12 Bookworm
    ["debian:trixie-slim"]="debian:13:" # Debian 13 Trixie
    ["ubuntu:questing"]="ubuntu:25.10:" # Ubuntu 25.10 Questing
    ["ubuntu:noble"]="ubuntu:24.04:" # Ubuntu 24.04 LTS Noble Numbat
    ["alpine:3.19"]="alpine:3.19:" # Alpine Linux 3.19
    ["alpine:3.23"]="alpine:3.23:" # Alpine Linux 3.23
    ["fedora:43"]="fedora:43:" # Fedora 43
    ["fedora:42"]="fedora:42:" # Fedora 42
    ["opensuse/tumbleweed"]="opensuse-tumbleweed::"
    ["opensuse/leap:15"]="opensuse-leap:15:" # openSUSE Leap 15
)

# Commands that should be installed by the setup script
REQUIRED_COMMANDS=(
    "bash"
    "chezmoi"
    "starship"
    "gcc"
    "eza"
    "bat"
    "curl"
    "wget"
    "git"
    "vim"
    "fastfetch"
    "fzf"
    "fd" # Special handling for fdfind on Debian/Ubuntu
    "rg" # ripgrep
    "nvim" # neovim
    "fish"
    "zoxide"
    "zsh"
    "tmux"
    "sudo"
    "tar"
)

echo "Starting system-setup.sh tests..."

for image in "${!TEST_IMAGES[@]}"; do
    distro_info="${TEST_IMAGES[$image]}"
    IFS=':' read -r distro_id version_id <<< "$distro_info"

    echo "----------------------------------------------------"
    echo "Testing on image: $image (Distro ID: $distro_id, Version ID: $version_id)"
    echo "----------------------------------------------------"

    container_name="test-$(echo "$image" | tr '[:punct:]/' '-')"
    
    # Pre-install curl if not present (some minimal images might not have it)
    PRE_INSTALL_CURL=""
    case "$distro_id" in
        "arch") PRE_INSTALL_CURL="pacman -Sy --noconfirm curl &&" ;;
        "debian" | "ubuntu") PRE_INSTALL_CURL="apt-get update && apt-get install -y curl &&" ;;
        "alpine") PRE_INSTALL_CURL="apk add curl &&" ;;
        "fedora") PRE_INSTALL_CURL="dnf install -y curl &&" ;;
        "opensuse-tumbleweed" | "opensuse-leap") PRE_INSTALL_CURL="zypper install -y curl &&" ;;
    esac

    # Build the command check string
    CHECKS_STR=""
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if [[ "$cmd" == "fd" && ("$distro_id" == "debian" || "$distro_id" == "ubuntu") ]]; then
            CHECKS_STR+="command -v fdfind >/dev/null || { echo '❌ fdfind not found'; ALL_COMMANDS_FOUND=false; } && "
        elif [[ "$cmd" == "bat" && ("$distro_id" == "debian" || "$distro_id" == "ubuntu") ]]; then
            CHECKS_STR+="command -v batcat >/dev/null || { echo '❌ batcat not found'; ALL_COMMANDS_FOUND=false; } && "
        elif [[ "$cmd" == "rg" ]]; then
            CHECKS_STR+="command -v rg >/dev/null || { echo '❌ ripgrep (rg) not found'; ALL_COMMANDS_FOUND=false; } && "
        elif [[ "$cmd" == "nvim" ]]; then
            CHECKS_STR+="command -v nvim >/dev/null || { echo '❌ neovim (nvim) not found'; ALL_COMMANDS_FOUND=false; } && "
        else
            CHECKS_STR+="command -v $cmd >/dev/null || { echo '❌ $cmd not found'; ALL_COMMANDS_FOUND=false; } && "
        fi
    done
    CHECKS_STR+="true" # Terminate the && list

    # Run container and execute setup script
    docker run --rm -i \
        --name "$container_name" \
        --privileged \
        -v "$SETUP_SCRIPT:/tmp/executable_system-setup.sh" \
        "$image" /bin/sh -c "$PRE_INSTALL_CURL chmod +x /tmp/executable_system-setup.sh && /tmp/executable_system-setup.sh && echo 'Verification started...' && ${CHECKS_STR}; if [ \"\$ALL_COMMANDS_FOUND\" = \"false\" ]; then echo '❌ Some required commands were not found.'; exit 1; else echo '✅ All required commands found.'; exit 0; fi"
    
    if [ $? -eq 0 ]; then
        echo "✅ Test passed for $image"
    else
        echo "❌ Test failed for $image"
        exit 1
    fi
done

echo "All tests completed successfully!"