# TODO
# 	- Use terminfo to set keybindings (as shown in Zsh's Arch Wiki)
# 	- Hide completion menu when typing
# 	- Fix history-substring-search skipping last commands
# 	- Make `cc` Vim command work when the command line is empty

################################################################################
# GENERAL

# HISTORY
HISTFILE=~/.cache/zsh/history
HISTSIZE=1000
SAVEHIST=10000
# Do not add duplicates to history
setopt histignoredups
# Append to history after each command
setopt incappendhistory
# # Ignore adjacent duplicates in history (used by history-substring-search)
setopt histfindnodups

# Autocomplete hidden files
setopt globdots

# Change terminal title
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		term_name=$(cat "/proc/$PPID/comm")
		term_name="$(tr '[:lower:]' '[:upper:]' <<< ${term_name:0:1})${term_name:1}"
		precmd () {print -Pn "\033]0;${PWD/#$HOME/\~} - ${term_name}\007"}
		;;
	screen*)
		precmd () {print -Pn "\033_${PWD/#$HOME/\~}\033\\"}
		;;
esac

# Enable color support
autoload -Uz colors && colors

# Set default LS_COLORS (used for colored menu)
source $ZDOTDIR/dircolors.default

# COLOR MAN PAGES
# Blink and bold (green)
export LESS_TERMCAP_mb=$'\033[01;32m'
export LESS_TERMCAP_md=$'\033[01;32m'
# Stop bold, blink and underline
export LESS_TERMCAP_me=$'\033[0m'
# Underline (cyan)
export LESS_TERMCAP_us=$'\033[04;36m'
# Stop underline
export LESS_TERMCAP_ue=$'\033[0m'
# Standout (black foreground, white background)
export LESS_TERMCAP_so=$'\033[00;47;30m'
# Stop standout
export LESS_TERMCAP_se=$'\033[0m'
# Output "raw" control characters in `less`
export LESS=-R

# set rg as fzf default command
if type rg &> /dev/null; then
	export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!**/.git'"
	export FZF_DEFAULT_OPTS='--bind=btab:up,tab:down --layout=reverse --no-multi'
fi

# Anaconda
# default Anaconda initialization is automatically placed at `~/.zshrc` even if
# the user's Zsh config file is not `~/.zshrc` (e.g. it may be
# `.config/zsh/.zshrc`); if `bin` and `condabin` directories exist inside
# `~/anaconda3` (the default installation path), as well as `~/.zshrc` we proceed
# to source the initialization script, which should be the only thing inside
# `~/.zshrc`
if [[ -d "$HOME/anaconda3/bin" && -d "$HOME/anaconda3/condabin"
	&& -f "$HOME/.zshrc" ]]; then
	source $HOME/.zshrc
fi

################################################################################
# PROMPT

parse_git_branch() {
	local ref=$(git branch 2>/dev/null | sed -n '/\* /s///p')
	if [ "$ref" != "" ] ; then
		echo " $ref"
	fi
}

setopt promptsubst

PS1='$(parse_git_branch)'
if [[ ${EUID} == 0 ]] ; then
 	PS1="%B%{$fg[red]%}[%S%n%s@%M %{$fg[blue]%}%~%{$fg[white]%}${PS1}%{$fg[red]%}]#%{$reset_color%}%b "
else
	PS1="%B%{$fg[green]%}[%M %{$fg[blue]%}%~%{$fg[white]%}${PS1}%{$fg[green]%}]$%{$reset_color%}%b "
fi

###############################################################################
# KEYBINDINGS

# VI MODE KEYS
bindkey -v
# Fixes escape key in Vi mode
export KEYTIMEOUT=1

# Fix backspace (behave as in vim rather than vi)
bindkey -v '^?' backward-delete-char

zmodload zsh/terminfo

# Home key
bindkey '^[[7~' vi-beginning-of-line
bindkey '^[[H' vi-beginning-of-line
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" vi-beginning-of-line
fi

# End key
bindkey '^[[8~' vi-end-of-line
bindkey '^[[F' vi-end-of-line
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" vi-end-of-line
fi

# Insert key
bindkey '^[[2~' overwrite-mode

# Delete key
bindkey '^[[3~' delete-char

# TODO: bind theese keys in vi mode
# bindkey '^[[5~' history-beginning-search-backward    # Page up key
# bindkey '^[[6~' history-beginning-search-forward     # Page down key

# Ctrl+arrow/backspace/delete keys
bindkey '^[Oc' vi-forward-word
bindkey '^[Od' vi-backward-word
bindkey '^[[1;5D' vi-backward-word
bindkey '^[[1;5C' vi-forward-word
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word

################################################################################
# COMPLETION

zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit

# zmodload zsh/complist

# # MENU
# # Highlight menu selection
# zstyle ':completion:*' menu select
# # <Shift+Tab> navigates backwards in menu
# bindkey -M menuselect '^[[Z' reverse-menu-complete
# # Run command when <Enter> is pressed in menu
# bindkey -M menuselect '^M' .accept-line
# # <Esc> exits menu and leaves command line untouched
# bindkey -M menuselect '\e' send-break

# Disable cycling through menu when hitting <Tab> more than once
unsetopt automenu
# Show completion menu on second <Tab> hit on ambiguous completion
setopt bashautolist

# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Automatically find new executables in path (recently installed executables)
zstyle ':completion:*' rehash true

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/cache

compinit

################################################################################
# ALIASES

# Enable color support for some commands
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c=auto'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

###############################################################################
# PLUGINS

# Syntax highlighting (must be sourced at the end)
if [[ -f "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
	source $HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f "$HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
	source $HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
	source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# SUBSTRING HISTORY SEARCH
if [[ -f "$HOME/.local/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
	source $HOME/.local/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
elif [[ -f "$HOME/.local/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
	source $HOME/.local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
elif [[ -f "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
	source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
elif [[ -f "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
	source /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh
fi
# Walk through history with Up-down/J-K keys
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# Highlighting colors
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=cyan,fg=white,bold"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=magenta,fg=white,bold"
# Find only exact matches
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS=""

# VI MODE CURSORS
# Disable plugin keybindings
VIM_MODE_NO_DEFAULT_BINDINGS=true
# Disable mode indicator in prompt
MODE_INDICATOR=""
# Source plugin
if [[ -f "$HOME/.local/share/zsh/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh" ]]; then
	source $HOME/.local/share/zsh/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh
elif [[ -f "$HOME/.local/share/zsh-vim-mode/zsh-vim-mode.plugin.zsh" ]]; then
	source $HOME/.local/share/zsh-vim-mode/zsh-vim-mode.plugin.zsh
elif [[ -f "/usr/share/zsh/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh" ]]; then
	source /usr/share/zsh/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh
elif [[ -f "/usr/share/zsh-vim-mode/zsh-vim-mode.plugin.zsh" ]]; then
	source /usr/share/zsh-vim-mode/zsh-vim-mode.plugin.zsh
fi
# Cursor shape depending on vi mode
MODE_CURSOR_VICMD="steady block"
MODE_CURSOR_VIINS="steady bar"
MODE_CURSOR_REPLACE="steady underline"
MODE_CURSOR_VISUAL="$MODE_CURSOR_VICMD"
MODE_CURSOR_VLINE="$MODE_CURSOR_VISUAL"
MODE_CURSOR_SEARCH="steady block"
