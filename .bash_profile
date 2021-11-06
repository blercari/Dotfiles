# Add `$HOME/.local/bin` to path if it isn't already and if directory exists
[[ ("$PATH" != *"$HOME/.local/bin"*) && (-d "$HOME/.local/bin") ]] && PATH=$PATH:$HOME/.local/bin
