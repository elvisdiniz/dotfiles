#!/usr/bin/env bash

if [ "$(darkman get)" = "light" ]; then
    plasma-apply-lookandfeel -a org.kde.breeze.desktop
    plasma-apply-desktoptheme breeze-light
    plasma-apply-colorscheme CatppuccinLatteLavender
    plasma-apply-cursortheme catppuccin-latte-light-cursors
else
    plasma-apply-lookandfeel -a org.kde.breezedark.desktop
    plasma-apply-desktoptheme breeze-dark
    plasma-apply-colorscheme CatppuccinMochaLavender
    plasma-apply-cursortheme catppuccin-mocha-dark-cursors
fi
