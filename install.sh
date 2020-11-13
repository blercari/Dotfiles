#!/bin/bash

dotfiles_dir=$(dirname $(readlink -f $0))

mkdir -p $HOME/.config

# .bashrc
rm -f $HOME/.bashrc
ln -s $dotfiles_dir/.bashrc $HOME

# Neovim
rm -f $HOME/.local/share/nvim/site/autoload/plug.vim
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

# Volume control script
mkdir -p $HOME/.local/bin
rm -rf $HOME/.local/bin/volctl
ln -s $dotfiles_dir/.local/bin/volctl $HOME/.local/bin
