# If not running interactively, don't do anything
[[ $- != *i* ]] && return

##############################################################################
# GENERAL

# Proper colors and compatibility issues
export TERM="xterm-256color"

# Don't put duplicate lines in history
HISTCONTROL=ignoredups

# Append to the history file, don't overwrite it
shopt -s histappend

# History lenght
HISTSIZE=1000
HISTFILESIZE=10000

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# Set vi mode in Bash shell
set -o vi
bind -m vi-insert 'Control-l: clear-screen'

# Bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Change terminal title
term_name=$(pstree -sA $$ | head -n1)
term_name=$(echo $term_name | awk -F "---" '{ print $(NF-2) }')
term_name="$(tr '[:lower:]' '[:upper:]' <<< ${term_name:0:1})${term_name:1}"
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		# PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/\~} - ${term_name}\007"'
		;;
	screen*)
		# PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		PROMPT_COMMAND='echo -ne "\033_${PWD/#$HOME/\~}\033\\"'
		;;
esac

# set rg as fzf default command
if type rg &> /dev/null; then
	export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!**/.git'"
	export FZF_DEFAULT_OPTS='--bind=btab:up,tab:down --layout=reverse --no-multi'
fi

##############################################################################
# PROMPT SETUP

parse_git_branch() {
	local ref=$(git branch 2>/dev/null | sed -n '/\* /s///p')
	if [ "$ref" != "" ] ; then
		echo " $ref"
	fi
}

bold="\[\033[1m\]"
invert="\[\033[7m\]"
red="\[\033[31m\]"
green="\[\033[32m\]"
blue="\[\033[34m\]"
white="\[\033[37m\]"
reset="\[\033[00m\]"

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

PS1='$(parse_git_branch)'
if [ "$color_prompt" = yes ]; then
	if [[ ${EUID} == 0 ]] ; then
		PS1="${bold}${red}[${invert}\u${reset}${bold}${red}@\h ${blue}\w${white}${PS1}${red}]\\$"${reset}" "
	else
		PS1="${bold}${green}[\h ${blue}\w${white}${PS1}${green}]\\$"${reset}" "
	fi
else
	PS1="[\h \w${PS1}]\\$"${reset}" "
fi

unset bold invert red green blue white reset color_prompt

##############################################################################
# ALIASES

# Enable color support for some commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

	alias ls='ls --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'

	alias diff='diff --color=auto'

	alias ip='ip -c=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
