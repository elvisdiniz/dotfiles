# My Dotfiles

My personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Prerequisites

Before installing, make sure you have the following installed:

- [Git](https://git-scm.com/)
- [chezmoi](https://chezmoi.io/install/)

## Compatible systems

I've successfully tested on the following systems:

- Archlinux
- Debian 12
- Ubuntu 22.04
- Alpine 3.18, 3.19 and 3.20
- FreeBSD 14
- MacOS Catalina and Ventura

## Installation

To install my dotfiles, you can use the following command:

```bash
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply elvisdiniz
```

To install dotfiles and remove all traces of chezmoi, run the following command:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot elvisdiniz
```

## Supported Platforms

- Linux
- macOS
- FreeBSD

## What's Included?

- **Shell Configuration:**
  - `bash`: `.bashrc` and `.bash_profile` for basic setup.
  - `zsh`: A more advanced setup with `.zshenv`, `.zshrc`, and plugins like `fzf-tab` and `zoxide`.
  - `fish`: Configuration with `config.fish` and a structured setup in `conf.d`.
- **Terminal Configuration:**
  - `alacritty`: Theming and basic configuration.
  - `kitty`: Theming and configuration.
  - `ghostty`: Basic configuration.
- **Editor Configuration:**
  - `neovim`: A customized setup with Lua, including `chadrc.lua` and various plugins.
  - `vscode`: `settings.json` for a consistent experience.
  - `zed`: `private_settings.json` for Zed editor settings.
- **Multiplexer Configuration:**
  - `tmux`: A `.tmux.conf` for a customized tmux experience.
  - `zellij`: Configuration with `config.kdl`.
- **Other Tools:**
  - `starship`: A minimal, blazing-fast, and infinitely customizable prompt.
  - `bat`: A `cat(1)` clone with syntax highlighting and Git integration.
  - `bottom`: A graphical process/system monitor.
  - `yazi`: A terminal file manager.
  - `fzf`: A command-line fuzzy finder.
  - `zoxide`: A smarter cd command.

## ZSH Plugins

- Zinit (plugin manager): <https://github.com/zdharma-continuum/zinit>
- Aloxaf/fzf-tab (tab completion with fzf): <https://github.com/Aloxaf/fzf-tab>
- Freed-Wu/fzf-tab-source (additional previews for fzf-tab plugin): <https://github.com/Freed-Wu/fzf-tab-source>
- zsh-users/zsh-autosuggestions (zsh autosuggestions): <https://github.com/zsh-users/zsh-autosuggestions>
- zdharma-continuum/fast-syntax-highlighting (zsh syntax-highlighting): <https://github.com/zdharma-continuum/fast-syntax-highlighting>
- jeffreytse/zsh-vi-mode (vim motions on ZSH): <https://github.com/jeffreytse/zsh-vi-mode>

## Tools and Technologies

This setup includes configurations for the following tools:

- **Shell:** Bash, Zsh, Fish
- **Terminal:** Alacritty, Kitty, Ghostty
- **Editor:** Neovim, VS Code, Zed
- **Multiplexer:** tmux, Zellij
- **Other Tools:** Starship, bat, bottom, yazi, and more.

## Extras

### Software Installation

Here are instructions to install some of the programs used in these dotfiles on various operating systems:

#### Archlinux

```bash
sudo pacman -Syu
sudo pacman -S eza bat curl git vim fzf fd ripgrep neovim bottom fish zsh
```

#### Ubuntu / Debian

```bash
sudo apt update
sudo apt install eza bat curl git vim fzf fd-find ripgrep neovim bottom fish zsh
# For fd, the package name is fd-find on Ubuntu/Debian
# For neovim, you might need to add a PPA for the latest version:
# sudo add-apt-repository ppa:neovim-ppa/stable
# sudo apt update
# sudo apt install neovim
```

#### Alpine Linux

```bash
sudo apk update
sudo apk add eza bat curl git vim fzf fd ripgrep neovim bottom fish zsh
```

#### FreeBSD

```bash
sudo pkg update
sudo pkg install eza bat curl git vim fzf fd ripgrep neovim bottom fish zsh
```

#### macOS (via Homebrew)

```bash
# Install Homebrew if you haven't already:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install eza bat curl git vim fzf fd ripgrep neovim bottom fish zsh
```
