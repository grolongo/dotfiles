if [[ -r "${HOME}/.exports" ]] && [[ -f "${HOME}/.exports" ]]; then
    source "${HOME}/.exports"
fi

# Réduire le temps de démarrage
skip_global_compinit=1

# umask
#umask 022
