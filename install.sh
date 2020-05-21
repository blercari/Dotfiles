#!/bin/bash

dotfiles_dir=$(dirname $(readlink -f $0))

mkdir -p $HOME/.config

# Neovim
rm -rf $HOME/.config/nvim
ln -s $dotfiles_dir/.config/nvim $HOME/.config

# Qtile
rm -rf $HOME/.config/qtile
ln -s $dotfiles_dir/.config/qtile $HOME/.config

# Awesome
rm -rf $HOME/.config/awesome
ln -s $dotfiles_dir/.config/awesome $HOME/.config

# Redshift
rm -rf $HOME/.config/redshift
ln -s $dotfiles_dir/.config/redshift $HOME/.config
