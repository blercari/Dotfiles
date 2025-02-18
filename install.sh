#!/bin/bash

dotfiles_dir=$(dirname $(readlink -f $0))

source $dotfiles_dir/prompt-for-multiselect.sh

components=("Bash" "Zsh" "Neovim" "Qtile" "Redshift" "KRunner runers scripts" "Volume control script")

bold=$(tput bold)
normal=$(tput sgr0)

###############################################################################
# ASK USER WHAT TO INSTALL

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
	# Link config files
	ln -sf $dotfiles_dir/.zshenv $HOME
	mkdir -p $HOME/.config
	mkdir -p $HOME/.cache/zsh
	rm -rf $HOME/.config/zsh
	ln -s $dotfiles_dir/.config/zsh $HOME/.config

	# Install plugins

	zsh_plugin_dir="$HOME/.local/share/zsh/plugins"
	mkdir -p $zsh_plugin_dir

	echo -e "\nInstalling Zsh plugins..."

	# zsh-syntax-highlighting
	rm -rf $zsh_plugin_dir/zsh-syntax-highlighting
	git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git \
	$zsh_plugin_dir/zsh-syntax-highlighting \
	|| echo "${bold}Unable to install zsh-syntax-highlighting plugin${normal}"

	# zsh-history-substring-search
	rm -rf $zsh_plugin_dir/zsh-history-substring-search
	git clone --quiet https://github.com/zsh-users/zsh-history-substring-search.git \
	$zsh_plugin_dir/zsh-history-substring-search \
	|| echo "${bold}Unable to install zsh-history-substring-search plugin${normal}"

	# zsh-vim-mode
	rm -rf $zsh_plugin_dir/zsh-vim-mode
	git clone --quiet https://github.com/softmoth/zsh-vim-mode.git \
	$zsh_plugin_dir/zsh-vim-mode \
	|| echo "${bold}Unable to install zsh-vim-mode plugin${normal}"

	# zsh-system-clipboard
	rm -rf $zsh_plugin_dir/zsh-system-clipboard
	git clone --quiet https://github.com/kutsan/zsh-system-clipboard.git \
	$zsh_plugin_dir/zsh-system-clipboard \
	|| echo "${bold}Unable to install zsh-system-clipboard plugin${normal}"

	unset zsh_plugin_dir
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

# KRunner runers scripts
if [[ " ${checked[@]} " =~ "KRunner runers scripts" ]]; then
	mkdir -p $HOME/.local/bin
	ln -sf $dotfiles_dir/.local/bin/run-krunner-applications-plugin $HOME/.local/bin
fi

# Volume control script
if [[ " ${checked[@]} " =~ "Volume control script" ]]; then
	mkdir -p $HOME/.local/bin
	ln -sf $dotfiles_dir/.local/bin/volctl $HOME/.local/bin
fi

###############################################################################
# PROMPT USER FOR CHANGING DEFAULT SHELL TO ZSH, IF IT WAS INTSTALLED

if [[ " ${checked[@]} " =~ "Zsh" ]]; then
	echo ""

	ans=""
	while [[ $ans != "y" && $ans != "n" ]]; do
		read -p "Set Zsh as default shell? [y/n] " ans
	done

	if [[ $ans == "y" ]]; then
		chsh --shell /usr/bin/zsh $USER \
		|| echo "${bold}Unable to set default shell to Zsh${normal}"
	fi
fi
