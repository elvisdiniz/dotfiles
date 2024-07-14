
# My dotfiles

## Summary and compatible systems

These repository contains my dotfiles. I've successfully tested on the following systems:

* Archlinux
* Debian 12
* Ubuntu 22.04
* Alpine 3.18, 3.19 and 3.20
* FreeBSD 14
* MacOS Catalina and Ventura

Probably will work on another systems, but i've not tested.

## Programs configured

### Shells

* ZSH
* Bash

### Terminals

* Alacritty
* Kitty

### Terminal multiplexers

* Zellij
* Tmux

### Text editors

* VIM
* NeoVim

### ZSH Plugins

* Zinit (plugin manager): <https://github.com/zdharma-continuum/zinit>
* Aloxaf/fzf-tab (tab completion with fzf): <https://github.com/Aloxaf/fzf-tab>
* Freed-Wu/fzf-tab-source (additional previews for fzf-tab plugin): <https://github.com/Freed-Wu/fzf-tab-source>
* zsh-users/zsh-autosuggestions (zsh autosuggestions): <https://github.com/zsh-users/zsh-autosuggestions>
* zdharma-continuum/fast-syntax-highlighting (zsh syntax-highlighting): <https://github.com/zdharma-continuum/fast-syntax-highlighting>
* jeffreytse/zsh-vi-mode (vim motions on ZSH): <https://github.com/jeffreytse/zsh-vi-mode>

### Misc

I've tried to use XDG recommended directories where was possible.

## Commands to install dotfiles using [chezmoi](https://www.chezmoi.io)

To install these dotfiles you neeed chezmoi installed on your system

### Install

#### Via system packagem manager (preferably)

You can install chezmoi from your system packagem manager. Chezmoi is available for all major platforms.

Homebrew (MacOS and Linux):

    brew install chezmoi

Pacman (Archlinux):

    pacman -S chezmoi

APT (Debian and derivatives):

    apt install chezmoi

PKG (FreeBSD):

    pkg install chezmoi

APK (Alpine):

    apk add chezmoi

#### Via binary package

To download the binary package from chezmoi and automatically install, use the following command:

    sh -c "$(curl -fsLS get.chezmoi.io/lb)"

### Initialize (only clone the repotitory on ~/.local/share/chezmoi)

    chezmoi init https://github.com/elvisdiniz/dotfiles.git

### Apply (apply the data cloned from the repository on home dir)

    chezmoi apply

### Initialize and apply (initialize and apply with only one command)

    chezmoi init --apply https://github.com/elvisdiniz/dotfiles.git

### Install and apply

Chezmoi's install script can run `chezmoi init` for you by passing extra arguments to the newly installed chezmoi binary. If your dotfiles repo is `github.com/$GITHUB_USERNAME/dotfiles` then installing chezmoi, running `chezmoi init`, and running `chezmoi apply` can be done in a single line of shell:

    sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply https://github.com/elvisdiniz/dotfiles.git

### Install, apply and then remove all traces of chezmoi

For setting up transitory environments (e.g. short-lived Linux containers) you can install chezmoi, install your dotfiles, and then remove all traces of chezmoi, including the source directory and chezmoi's configuration directory, with a single command:

    sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --one-shot https://github.com/elvisdiniz/dotfiles.git

If your dotfiles repo is on github and named "dotfiles", you can use only your github username to chezmoi. For example:

    chezmoi init --apply elvisdiniz

# Extra

## Additional softwares

With the configs above, everything should work fine, with default unix binaries, like ls, find, cat etc. But is recommended to install some more modern tools like eza, fd, bat etc.
The scripts will utilize these utilities when available on the system.
Here are some some recommended applications with installations commands.

### Homebrew

I recommend installing Homebrew package manager on MacOS and Linux (especially on Debian). Can be installed with the following command:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Obs.: the configs on dotfiles will automatically identify the homebrew installation and load paths and completions. You only need to reload the shell after the installation.

### Debian based distros

Install bat, curl, git, vim and zsh programs:
using sudo:

    sudo apt update && sudo apt install -y bat curl git vim zsh

Eza, fd and fzf are very outdated on official repositories, I recommend using Homebrew versions:

    brew install eza fd fzf

### Archlinux

Install eza, bat, curl, git, vim, fzf, fd, ripgrep and zsh:

    sudo pacman -Suy eza bat curl git vim fzf fd ripgrep zsh

### Alpine

Install eza, bat, curl, git, vim, fzf, fd, ripgrep and zsh:

    sudo apk add eza bat curl git vim fzf fd ripgrep zsh

### FreeBSD

Install eza, bat, curl, git, vim, fzf, fd-find, ripgrep and zsh:

    sudo pkg install eza bat curl git vim fzf fd-find ripgrep zsh

### MacOS (needs homebrew)

Install eza, bat, curl, vim, fzf, fd, ripgrep and zsh:

    brew install eza bat curl git vim fzf fd ripgrep zsh

## Other configurations

### Set zsh as default shell

    [ -x "$(command -v zsh)" ] && chsh -s $(command -v zsh) $USER
