
# dotfiles

## commands to install dotfiles using [chezmoi](https://www.chezmoi.io)

### install

    sh -c "$(curl -fsLS get.chezmoi.io/lb)"

### initialize

    chezmoi init https://github.com/elvisdiniz/dotfiles.git

### initialize and apply

    chezmoi init --apply https://github.com/elvisdiniz/dotfiles.git

### install and apply

chezmoi's install script can run `chezmoi init` for you by passing extra arguments to the newly installed chezmoi binary. If your dotfiles repo is `github.com/$GITHUB_USERNAME/dotfiles` then installing chezmoi, running `chezmoi init`, and running `chezmoi apply` can be done in a single line of shell:

    sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply elvisdiniz

### install, apply and then remove all traces of chezmoi

For setting up transitory environments (e.g. short-lived Linux containers) you can install chezmoi, install your dotfiles, and then remove all traces of chezmoi, including the source directory and chezmoi's configuration directory, with a single command:

    sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --one-shot elvisdiniz

# extra

## manualy install additional softwares

### debian based distros:

install sudo, exa, bat, curl, git, vim and zsh programs:
using sudo:

    sudo apt update && sudo apt install -y sudo exa bat curl git vim zsh

as root:

    apt update && apt install -y sudo exa bat curl git vim zsh

run ubuntu on docker with dotfiles

    docker run -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -it --rm ubuntu sh -uec 'apt update && apt install -y sudo exa bat curl git vim zsh && sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --one-shot elvisdiniz && exec zsh'

### archlinux:

install exa, bat, curl, git, vim and zsh programs:
using sudo:

    sudo pacman -Suy exa bat curl git vim zsh

as root:

    pacman -Suy exa bat curl git vim zsh

run arch on docker with dotfiles

    docker run -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -it --rm archlinux sh -uec 'pacman --noconfirm -Suy exa bat curl git vim zsh && sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --one-shot elvisdiniz && exec zsh'

### alpine

run alpine on docker with dotfiles

    docker run -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -it --rm alpine sh -uec 'apk add sudo exa bat curl git vim zsh && sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --one-shot elvisdiniz && exec zsh'

## other configurations

### set zsh as default shell:

    [[ ! -x /usr/bin/zsh ]] || chsh -s /usr/bin/zsh $USER
