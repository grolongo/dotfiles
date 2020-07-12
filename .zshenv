if [[ -r "$HOME/.exports" ]] && [[ -f "$HOME/.exports" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.exports"
fi
