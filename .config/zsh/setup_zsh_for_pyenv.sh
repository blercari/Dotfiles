# Add Pyenv to path initialize it
if [[ ("$PATH" != *"$HOME/.pyenv"*) && (-d "$HOME/.pyenv") ]]; then
	export PYENV_ROOT="$HOME/.pyenv"
	command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init -)"
fi

