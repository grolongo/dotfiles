#!/usr/bin/env bash
set -e
set -u
set -o pipefail
IFS=$'\n\t'

# check if we are in the correct folder
[ -e symlinks-unix.sh ] || { printf "Please cd into the install dir before running this script.\n" >&2; exit 1; }

# base variable for where are our dotfiles
base="${PWD%/*}"

# yes/no prompt
confirm() {
    while true; do
        read -r -p "$1 [y/n] " choice
        case "$choice" in
            [yY]es|[yY])
                return 0
                ;;
            [nN]o|[nN])
                return 1
                ;;
            *)
                printf "Please enter yes or no.\n"
                ;;
        esac
    done
}

# ln
symlink() {
    sourcefile="${base}"/"$1"
    targetlink="${HOME}"/"$1"

    if [ -e "$sourcefile" ]; then
        ln -sniv "$sourcefile" "$targetlink"
    else
        printf '%s does not exist.\n' "$sourcefile" >&2
    fi
}

# user symlinks
echo
confirm "Install symlinks for ${USER}?" && {

    # zsh
    confirm "link zsh files?" && {
        mkdir -vp "${HOME}/.cache/zsh"
        symlink ".zshrc"
        symlink ".zshenv"
        symlink ".aliases"
        symlink ".exports"
        #symlink ".zlogin" # pour i3
    }

    # bash
    confirm "link bash files?" && {
        mkdir -vp "${HOME}/.cache/bash"
        symlink ".bashrc"
        symlink ".inputrc"
        symlink ".aliases"
        symlink ".exports"
    }

    # emacs
    # confirm "link emacs config?" && {
    #     mkdir -vp "${HOME}"/.config/emacs
    #     symlink ".config/emacs/init.el"
    #     symlink ".config/emacs/early-init.el"
    # }

    # chatty
    confirm "link chatty files?" && {
        mkdir -vp "${HOME}/.chatty"
        symlink ".chatty/settings"
    }

    # mpv
    confirm "link mpv files?" && {
        mkdir -vp "${HOME}/.config/mpv"
        mkdir -vp "${HOME}/.config/mpv/scripts"
        symlink ".config/mpv/input.conf"
        symlink ".config/mpv/mpv.conf"
        symlink ".config/mpv/scripts/osctoggle.lua"
        symlink ".config/mpv/script-opts"
    }

    # tmux
    confirm "link tmux config file?" && {
        mkdir -vp "${HOME}/.config/tmux"
        symlink ".config/tmux/tmux.conf"
    }

    # rtorrent
    confirm "link rtorrent config file?" && {
        mkdir -vp "${HOME}/Downloads"
        mkdir -vp "${HOME}/.cache/rtorrent"
        symlink ".config/rtorrent/rtorrent.rc"
    }

    # aria2
    confirm "link aria2 config file?" && {
        mkdir -vp "${HOME}/.config/aria2"
        symlink ".config/aria2/aria2.conf"
    }

    # vim
    confirm "link vim files?" && {
        mkdir -vp "${HOME}/.vim"
        symlink ".vimrc"
    }

    # git
    confirm "link gitconfig file?" && {
        mkdir -vp "${HOME}/.config/git"
        symlink ".config/git/config"
    }

    # streamlink
    confirm "link streamlink config file?" && {
        if [ "$(uname)" = Darwin ]; then
            ln -sniv "${base}/.config/streamlink/config" "${HOME}/Library/Application Support/streamlink/config"
        else
            mkdir -vp "${HOME}/.config/streamlink"
            symlink ".config/streamlink/config"
        fi
    }

    # dunst
    confirm "link dunst config file?" && {
        mkdir -vp "${HOME}/.config/dunst"
        symlink ".config/dunst/dunstrc"
    }

    # i3
    confirm "link i3 files?" && {
        mkdir -vp "${HOME}/.config/i3"
        mkdir -vp "${HOME}/.config/i3status"
        symlink ".config/i3/config"
        symlink ".config/i3status/config"
    }

    # X
    confirm "link Xresources config file?" && {
        symlink ".Xresources"
    }

    # bin
    confirm "link binary files?" && {
        mkdir -vp "${HOME}/.local/bin"
        symlink ".local/bin/extract"
        chmod +x "${HOME}"/.local/bin/*
    }

}
