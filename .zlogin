[[ -z $DISPLAY && $XDG_VTNR -le 1 ]] && exec startx
eval "$(gpg-agent --daemon)"
