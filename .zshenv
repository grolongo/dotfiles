# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,exports,extra}; do
  if [[ -r "$file" ]] && [[ -f "$file" ]]; then
    # shellcheck source=/dev/null
    source "$file"
  fi
done

### PATH

export PATH="/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/usr/sbin:/sbin:${PATH}"

# add home bin if exists
if [ -d "${HOME}/bin" ]; then
  export PATH="${HOME}/bin:${PATH}"
fi

# add pip3 binaries
if [ -d "${HOME}/.local/bin" ]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi

unset file

# Réduire le temps de démarrage
skip_global_compinit=1
setopt noglobalrcs # doesn't load /etc/zprofile, zshrc & zlogin

# umask
umask 022
