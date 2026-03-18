# Gemini Code Assistant Project Overview

This document provides a summary of the `dotfiles` project, intended to help the Gemini code assistant understand the project's structure, conventions, and commands.

## Project Summary

This is a personal dotfiles repository managed by [chezmoi](https://www.chezmoi.io/). It is used to maintain a consistent development environment and tool configuration across multiple machines and operating systems (Linux, macOS, FreeBSD).

The repository configures a wide range of tools, including shells, editors, terminals, and various command-line utilities, with a preference for the Catppuccin color scheme.

## Key Technologies

- **Dotfile Manager**: `chezmoi`
- **Shells**: `zsh` (primary), `bash`, `fish`
- **Terminal Multiplexers**: `tmux`, `zellij`
- **Editors**: `Neovim` (primary, with Lua configuration), `VS Code`, `Vim`, `Zed`
- **Terminals**: `Alacritty`, `Kitty`, `Ghostty`
- **Shell Tools**:
  - `starship`: Cross-shell prompt
  - `eza`: `ls` replacement
  - `bat`: `cat` replacement with syntax highlighting
  - `zoxide`: "Smarter" `cd` command
  - `fzf`: Command-line fuzzy finder
  - `ripgrep`: Fast, recursive search tool
- **System Monitoring**: `btop`, `bottom`
- **Package Lists**: `pacman` (Arch), `vscode-extensions.txt`
- **Containerization**: A `.devcontainer` is configured for use with VS Code Dev Containers.

## Project Structure

The repository follows `chezmoi` conventions.

- `dot_*`: Files and directories prefixed with `dot_` are symlinked into the user's home directory with the prefix removed (e.g., `dot_bashrc` becomes `~/.bashrc`).
- `dot_config/`: Contains configurations for tools that follow the XDG Base Directory Specification (e.g., `~/.config/nvim`).
- `dot_local/`: Contains local user data, including binaries (`bin/`) and scripts (`scripts/`).
- `executable_*`: Files with this prefix are marked as executable by `chezmoi`.
- `private_*`: Files with this prefix are encrypted by `chezmoi` and are not committed in plaintext.
- `*.tmpl`: These are `chezmoi` templates, which are processed to generate the final configuration files.
- `install.sh`: A script to install `chezmoi` and apply the dotfiles.
- `dot_local/bin/executable_system-setup.sh`: A comprehensive script for setting up a new system by installing necessary packages and tools for various Linux distributions, macOS, and FreeBSD.

## Common Commands

- **Apply dotfiles**:

  ```bash
  chezmoi apply
  ```

- **Initial setup on a new machine**:

  ```bash
  # The install.sh script installs chezmoi and runs 'chezmoi init --apply'
  ./install.sh
  ```

- **System-wide package installation**:
  The `system-setup.sh` script is used to provision a new machine with required software. It's designed to be run with `sudo` and supports various OSes.

  ```bash
  # Example usage (from within the repo)
  sudo ./dot_local/bin/executable_system-setup.sh
  ```

## Code Style and Conventions

- **Lua (Neovim)**: `stylua` is used for formatting Lua code. The configuration is in `dot_config/nvim/stylua.toml`.
- **Shell Scripts**: Scripts are written in `sh` (POSIX) for portability where possible. They include `set -e` and `set -u` for robustness.
- **General**: There are no other project-wide linters or formatters. The primary goal is consistency with the established style in each configuration file.
