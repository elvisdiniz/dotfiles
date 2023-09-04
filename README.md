# dotfiles

## install

    sh -c "$(curl -fsLS get.chezmoi.io/lb)"

## initialize

    chezmoi init https://github.com/elvisdiniz/dotfiles.git

## initialize and apply

    chezmoi init --apply https://github.com/elvisdiniz/dotfiles.git

## install and apply

    sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply elvisdiniz
