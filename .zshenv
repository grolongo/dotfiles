# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,exports,extra}; do
  if [[ -r "$file" ]] && [[ -f "$file" ]]; then
    # shellcheck source=/dev/null
    source "$file"
  fi
done
unset file

# Réduire le temps de démarrage
skip_global_compinit=1
setopt noglobalrcs # doesn't load /etc/zprofile, zshrc & zlogin

# umask
umask 022
