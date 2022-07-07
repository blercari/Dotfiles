#!/bin/bash

dotfiles_dir=$(dirname $(readlink -f $0))

source $dotfiles_dir/prompt-for-multiselect.sh

components=("Bash" "Zsh" "Neovim" "Qtile" "Redshift" "Volume control script")

###############################################################################
# ASK USER WHAT TO INSTALL

bold=$(tput bold)
normal=$(tput sgr0)

echo -n "Choose config files to install (${bold}SPACE${normal} to select,"
echo " ${bold}ENTER${normal} to confirm):"

for i in "${!components[@]}"; do
	options_string+="${components[$i]};"
done

prompt_for_multiselect SELECTED "$options_string"

for i in "${!SELECTED[@]}"; do
	if [ "${SELECTED[$i]}" == "true" ]; then
		checked+=("${components[$i]}")
	fi
done

unset bold normal

###############################################################################
# INSTALLATION

if [[ -z ${checked} ]]; then
	echo "Nothing was installed."
	exit 0
fi

# Bash
if [[ " ${checked[@]} " =~ "Bash" ]]; then
	ln -sf $dotfiles_dir/.bashrc $HOME
	ln -sf $dotfiles_dir/.bash_profile $HOME
fi

# Zsh
if [[ " ${checked[@]} " =~ "Zsh" ]]; then
	ln -sf $dotfiles_dir/.zshenv $HOME
	mkdir -p $HOME/.config
	mkdir -p $HOME/.cache/zsh
	rm -rf $HOME/.config/zsh
	ln -s $dotfiles_dir/.config/zsh $HOME/.config
fi

# Neovim
if [[ " ${checked[@]} " =~ "Neovim" ]]; then
	rm -f $HOME/.local/share/nvim/site/autoload/plug.vim
	mkdir -p $HOME/.config
	rm -rf $HOME/.config/nvim
	ln -s $dotfiles_dir/.config/nvim $HOME/.config
fi

# Qtile
if [[ " ${checked[@]} " =~ "Qtile" ]]; then
	mkdir -p $HOME/.config
	rm -rf $HOME/.config/qtile
	ln -s $dotfiles_dir/.config/qtile $HOME/.config
fi

# Redshift
if [[ " ${checked[@]} " =~ "Redshift" ]]; then
	mkdir -p $HOME/.config
	rm -rf $HOME/.config/redshift
	ln -s $dotfiles_dir/.config/redshift $HOME/.config
fi

# Volume control script
if [[ " ${checked[@]} " =~ "Volume control script" ]]; then
	mkdir -p $HOME/.local/bin
	ln -sf $dotfiles_dir/.local/bin/volctl $HOME/.local/bin
fi
