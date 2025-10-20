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
    local package_name=""

    case "$ID" in
    "debian" | "ubuntu")
        file_ext="deb"
        package_name="chezmoi_${latest_version}_linux_${machine}.${file_ext}"
        download_url="https://github.com/twpayne/chezmoi/releases/download/v${latest_version}/${package_name}"
        ;;
    "fedora")
        file_ext="rpm"
        local arch=$(uname -m)
        package_name="chezmoi-${latest_version}-${arch}.rpm"
        download_url="https://github.com/twpayne/chezmoi/releases/download/v${latest_version}/${package_name}"
        ;;
    *)
        error "Unsupported Linux distribution for chezmoi installation: $ID"
        exit 1
        ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading chezmoi from ${download_url}"
    curl -L "$download_url" -o "${package_name}"

    info "Verifying checksum..."
    local checksum_url="https://github.com/twpayne/chezmoi/releases/download/v${latest_version}/chezmoi_${latest_version}_checksums.txt"
    curl -L "$checksum_url" -o "checksums.txt"
    local expected_checksum=$(grep "${package_name}" checksums.txt | cut -d ' ' -f 1)
    local actual_checksum=$(sha256sum "${package_name}" | cut -d ' ' -f 1)

    if [ "$expected_checksum" != "$actual_checksum" ]; then
        error "Checksum verification failed."
        rm -rf "$temp_dir"
        exit 1
    fi
    info "Checksum verified."

    case "$ID" in
    "debian" | "ubuntu")
        run_as_root dpkg -i "${package_name}"
        ;;
    "fedora")
        run_as_root rpm -i "${package_name}"
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
    local package_name=""

    case "$ID" in
    "debian" | "ubuntu")
        file_ext="deb"
        package_name="fastfetch-linux-${machine}.${file_ext}"
        download_url="https://github.com/fastfetch-cli/fastfetch/releases/download/${latest_version}/${package_name}"
        ;;
    *)
        error "Unsupported Linux distribution for fastfetch installation: $ID"
        exit 1
        ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading fastfetch from ${download_url}"
    curl -L "$download_url" -o "${package_name}"

    info "Verifying checksum..."
    local checksum_url="${download_url}.sha256"
    curl -L "$checksum_url" -o "checksum.txt"
    local expected_checksum=$(cat checksum.txt)
    local actual_checksum=$(sha256sum "${package_name}" | cut -d ' ' -f 1)

    if [ "$expected_checksum" != "$actual_checksum" ]; then
        error "Checksum verification failed."
        rm -rf "$temp_dir"
        exit 1
    fi
    info "Checksum verified."

    case "$ID" in
    "debian" | "ubuntu")
        run_as_root dpkg -i "${package_name}"
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
    local package_name=""

    case "$ID" in
    "debian" | "ubuntu")
        file_ext="deb"
        package_name="zoxide_${latest_version}-1_${machine}.${file_ext}"
        download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${latest_version}/${package_name}"
        ;;
    "opensuse-leap")
        file_ext="tar.gz"
        local arch
        arch=$(uname -m)
        package_name="zoxide-${latest_version}-${arch}-unknown-linux-musl.${file_ext}"
        download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${latest_version}/${package_name}"
        ;;
    *)
        error "Unsupported Linux distribution for zoxide installation: $ID"
        exit 1
        ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading zoxide from ${download_url}"
    curl -L "$download_url" -o "${package_name}"

    info "Verifying checksum..."
    local checksum_url=""
    case "$ID" in
    "debian" | "ubuntu")
        checksum_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${latest_version}/zoxide_${latest_version}-1_${machine}.deb.sha256sum"
        ;;
    "opensuse-leap")
        local arch=$(uname -m)
        checksum_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${latest_version}/zoxide-${latest_version}-${arch}-unknown-linux-musl.tar.gz.sha256"
        ;;
    esac

    curl -L "$checksum_url" -o "checksum.txt"
    local expected_checksum=$(cat checksum.txt | cut -d ' ' -f 1)
    local actual_checksum=$(sha256sum "${package_name}" | cut -d ' ' -f 1)

    if [ "$expected_checksum" != "$actual_checksum" ]; then
        error "Checksum verification failed."
        rm -rf "$temp_dir"
        exit 1
    fi
    info "Checksum verified."

    case "$ID" in
    "debian" | "ubuntu")
        run_as_root dpkg -i "${package_name}"
        ;;
    "opensuse-leap")
        run_as_root mkdir -p /usr/local/bin
        run_as_root chown root:root /usr/local/bin
        info "Extracting zoxide..."
        tar -xzf "${package_name}"
        run_as_root chown -R root:root "$temp_dir"
        run_as_root mv zoxide /usr/local/bin/zoxide
        run_as_root chmod +x /usr/local/bin/zoxide
        run_as_root mkdir -p /usr/local/share/man/man1
        run_as_root mv man/man1/zoxide*.1 /usr/local/share/man/man1/
        run_as_root mkdir -p /usr/local/share/zsh/site-functions
        run_as_root mv completions/_zoxide /usr/local/share/zsh/site-functions/_zoxide
        run_as_root mkdir -p /usr/local/share/bash-completion/completions
        run_as_root mv completions/zoxide.bash /usr/local/share/bash-completion/completions/zoxide.bash
        run_as_root mkdir -p /usr/share/fish/vendor_completions.d
        run_as_root mv completions/zoxide.fish /usr/share/fish/vendor_completions.d/zoxide.fish
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
    local package_name=""

    case "$ID" in
    "debian" | "ubuntu")
        file_ext="deb"
        package_name="bottom_${latest_version}-1_${machine}.${file_ext}"
        download_url="https://github.com/ClementTsang/bottom/releases/download/${latest_version}/${package_name}"
        ;;
    *)
        error "Unsupported Linux distribution for bottom installation: $ID"
        exit 1
        ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading bottom from ${download_url}"
    curl -L "$download_url" -o "${package_name}"

    info "Verifying checksum..."
    local checksum_url="${download_url}.sha256"
    curl -L "$checksum_url" -o "checksum.txt"
    local expected_checksum=$(cat checksum.txt | cut -d ' ' -f 1)
    local actual_checksum=$(sha256sum "${package_name}" | cut -d ' ' -f 1)

    if [ "$expected_checksum" != "$actual_checksum" ]; then
        error "Checksum verification failed."
        rm -rf "$temp_dir"
        exit 1
    fi
    info "Checksum verified."

    case "$ID" in
    "debian" | "ubuntu")
        run_as_root dpkg -i "${package_name}"
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
    local file_ext="tar.gz"
    local bin_package_name="eza_${machine}-unknown-linux-gnu.${file_ext}"
    local completions_package_name="completions-${latest_version}.${file_ext}"
    local man_package_name="man-${latest_version}.${file_ext}"

    local bin_download_url="https://github.com/eza-community/eza/releases/download/v${latest_version}/${bin_package_name}"
    local completions_download_url="https://github.com/eza-community/eza/releases/download/v${latest_version}/${completions_package_name}"
    local man_download_url="https://github.com/eza-community/eza/releases/download/v${latest_version}/${man_package_name}"

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    info "Downloading eza from ${bin_download_url}"
    curl -L "$bin_download_url" -o "${bin_package_name}"
    curl -L "$completions_download_url" -o "${completions_package_name}"
    curl -L "$man_download_url" -o "${man_package_name}"

    info "Verifying checksums..."
    local bin_checksum_url="${bin_download_url}.sha256"
    curl -L "$bin_checksum_url" -o "bin_checksum.txt"
    local expected_bin_checksum=$(cat bin_checksum.txt)
    local actual_bin_checksum=$(sha256sum "${bin_package_name}" | cut -d ' ' -f 1)

    if [ "$expected_bin_checksum" != "$actual_bin_checksum" ]; then
        error "Binary checksum verification failed."
        rm -rf "$temp_dir"
        exit 1
    fi
    info "Binary checksum verified."

    local completions_checksum_url="${completions_download_url}.sha256"
    curl -L "$completions_checksum_url" -o "completions_checksum.txt"
    local expected_completions_checksum=$(cat completions_checksum.txt)
    local actual_completions_checksum=$(sha256sum "${completions_package_name}" | cut -d ' ' -f 1)

    if [ "$expected_completions_checksum" != "$actual_completions_checksum" ]; then
        error "Completions checksum verification failed."
        rm -rf "$temp_dir"
        exit 1
    fi
    info "Completions checksum verified."

    local man_checksum_url="${man_download_url}.sha256"
    curl -L "$man_checksum_url" -o "man_checksum.txt"
    local expected_man_checksum=$(cat man_checksum.txt)
    local actual_man_checksum=$(sha256sum "${man_package_name}" | cut -d ' ' -f 1)

    if [ "$expected_man_checksum" != "$actual_man_checksum" ]; then
        error "Man pages checksum verification failed."
        rm -rf "$temp_dir"
        exit 1
    fi
    info "Man pages checksum verified."


    info "Extracting eza..."

    mkdir -p /usr/local/bin
    run_as_root tar -xzf "${bin_package_name}" --directory=/usr/local/bin
    chmod +x /usr/local/bin/eza
    mkdir completions
    tar -xzf "${completions_package_name}" --directory=completions
    run_as_root mkdir -p /usr/local/share/zsh/site-functions
    run_as_root mkdir -p /usr/local/share/bash-completion/completions
    run_as_root mkdir -p /usr/share/fish/vendor_completions.d
    run_as_root mv "$temp_dir/completions/target/completions-${latest_version}/_eza" /usr/local/share/zsh/site-functions/_eza
    run_as_root mv "$temp_dir/completions/target/completions-${latest_version}/eza" /usr/local/share/bash-completion/completions/eza
    run_as_root mv "$temp_dir/completions/target/completions-${latest_version}/eza.fish" /usr/share/fish/vendor_completions.d/eza.fish
    mkdir man
    tar -xzf "${man_package_name}" --directory=man
    mkdir -p /usr/local/share/man/man1
    run_as_root mv "$temp_dir/man/target/man-${latest_version}/eza.1" /usr/local/share/man/man1/eza.1
    mkdir -p /usr/local/share/man/man5
    run_as_root mv "$temp_dir/man/target/man-${latest_version}/eza_colors.5" /usr/local/share/man/man5/eza_colors.5
    run_as_root mv "$temp_dir/man/target/man-${latest_version}/eza_colors-explanation.5" /usr/local/share/man/man5/eza_colors-explanation.5

    info "eza installed successfully."

    cd -
    rm -rf "$temp_dir"
}

# Function to install packages on Arch Linux
setup_arch() {
    info "Installing packages for Arch Linux..."
    run_as_root pacman -Syu --noconfirm
    run_as_root pacman -S --noconfirm --needed \
        chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux sudo
}

# Function to install packages on Debian/Ubuntu
setup_debian_ubuntu() {
    info "Installing packages for Debian/Ubuntu..."
    add_eza_apt_repository
    run_as_root apt-get update
    local packages="bat curl eza wget git vim fzf fd-find ripgrep neovim fish zsh tmux"
    if [ "$ID" = "debian" ]; then
        if [ "$VERSION_ID" -ge 13 ]; then
            packages="$packages fastfetch btm zoxide starship"
        else
            install_zoxide
            install_fastfetch
            install_bottom
        fi
    fi
    if [ "$ID" = "ubuntu" ]; then
        packages="$packages zoxide btm"
        if [ "$(echo "$VERSION_ID" | cut -d. -f1)" -ge 25 ]; then
            packages="$packages starship fastfetch"
        else
            install_fastfetch
        fi
    fi
    run_as_root apt-get install -y $packages
    install_chezmoi
}

# Function to install packages on Alpine Linux
setup_alpine() {
    info "Installing packages for Alpine Linux..."
    run_as_root apk update
    run_as_root apk add chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux sudo
}

# Function to install packages on Fedora
setup_fedora() {
    info "Installing packages for Fedora..."
    local packages="bat curl wget git vim fastfetch fzf fd-find ripgrep neovim fish zoxide zsh tmux procps-ng"
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
    local packages="chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zsh tmux sudo"
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
    run_as_root pkg install -y chezmoi starship eza bat curl wget git vim fastfetch fzf fd ripgrep neovim bottom fish zoxide zsh tmux sudo
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
