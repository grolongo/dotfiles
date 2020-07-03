if [[ -r "$HOME/.exports" ]] && [[ -f "$HOME/.exports" ]]; then
    source "$HOME/.exports"
fi

# variable to allow using up-line-or-beginning-search
# on Debian like systems
DEBIAN_PREVENT_KEYBOARD_CHANGES=yes

#umask 022
