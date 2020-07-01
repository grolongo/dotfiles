if [[ -r "${HOME}"/.exports ]] && [[ -f "${HOME}"/.exports ]]; then
    source "${HOME}"/.exports
fi

unset file

# Réduire le temps de démarrage
skip_global_compinit=1
setopt noglobalrcs # doesn't load /etc/zprofile, zshrc & zlogin

# umask
umask 022
