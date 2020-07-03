if [[ -r "$HOME/.exports" ]] && [[ -f "$HOME/.exports" ]]; then
    source "$HOME/.exports"
fi

# This variable is used to allow using
# up-line-or-beginning-search (and down)
# commands with the arrow keys to scroll
# history on Debian like systems.
DEBIAN_PREVENT_KEYBOARD_CHANGES=yes

#umask 022
