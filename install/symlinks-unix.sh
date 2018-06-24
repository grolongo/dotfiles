#!/bin/bash

# check if running compatible OS
[[ $OSTYPE = darwin* || $OSTYPE = linux* ]] || { echo >&2 "You are not running macOS or Linux. Exiting."; exit 1; }

# check if we are in the correct folder
[[ -e symlinks-unix.sh ]] || { echo >&2 "Please cd into the install dir before running this script."; exit 1; }

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
        echo "Please enter yes or no."
      ;;
    esac
  done
}

# ln
symlink() {
  sourcefile="$base"/"$1"
  targetlink="$HOME"/"$1"

  if [[ ! -e "$sourcefile" ]]; then
    echo >&2 "$sourcefile doesn't exist"
  else
    ln -sniv "$sourcefile" "$targetlink"
  fi
}

# user symlinks
echo
confirm "Install symlinks for $USER?" && {

  # zsh
  confirm "link zsh files?" && {
    symlink ".zshrc"
    symlink ".zshenv"
    symlink ".dircolors"
    symlink ".aliases"
    symlink ".functions"
    symlink ".path"
    symlink ".exports"
    #symlink ".zsh_prompt"
    #symlink ".zlogin" # pour i3
  }

  # gnupg
  confirm "link gpg files?" && {
    mkdir -vp "$HOME"/.gnupg
    chmod 700 "$HOME"/.gnupg
    symlink ".gnupg/gpg.conf"
    chmod 600 "$HOME"/.gnupg/gpg.conf
    symlink ".gnupg/gpg-agent.conf"
    chmod 600 "$HOME"/.gnupg/gpg-agent.conf
    symlink ".gnupg/dirmngr.conf"
    chmod 600 "$HOME"/.gnupg/dirmngr.conf
  }

  # ssh
  confirm "link ssh files?" && {
    if [[ $(uname -r) =~ Microsoft ]]; then
      echo "Please use './install-wsl ssh' to copy SSH files. Can't use symlinks because of permission issues with Windows SSH files."
    else
      mkdir -vp "$HOME"/.ssh
      chmod 700 "$HOME"/.ssh
      symlink ".ssh/config"
      symlink ".ssh/id_rsa"
      symlink ".ssh/id_rsa.pub"
      chmod 600 "$HOME"/.ssh/*
    fi
  }

  # chatty
  confirm "link chatty files?" && {
    mkdir -vp "$HOME"/.chatty
    symlink ".chatty/settings"
  }
  
  # mpv
  confirm "link mpv files?" && {
    mkdir -vp "$HOME"/.config/mpv
    symlink ".config/mpv/input.conf"
    symlink ".config/mpv/mpv.conf"
  }
  
  # tmux
  confirm "link tmux config file?" && {
    symlink ".tmux.conf"
  }
  
  # rtorrent
  confirm "link rtorrent config file?" && {
    mkdir -vp "$HOME"/.rtorrent.session
    mkdir -vp "$HOME"/Downloads
    symlink ".rtorrent.rc"
  }
  
  ## weechat
  #confirm "link weechat files?" && {
  #  mkdir -vp "$HOME"/.weechat
  #  symlink ".weechat/irc.conf"
  #  symlink ".weechat/weechat.conf"
  #  symlink ".weechat/logger.conf"
  #}
  
  # vim
  confirm "link vim files?" && {
    mkdir -vp "$HOME"/.vim
    symlink ".vimrc"
  }

  # neovim
  confirm "link neovim files?" && {
    mkdir -vp "$HOME"/.config/nvim
    symlink ".config/nvim/init.vim"
    symlink ".config/nvim/ultisnippets"
    mkdir -vp "$HOME"/.config/nvim/after
    symlink ".config/nvim/after/syntax"
    symlink ".mdlrc"
    symlink ".vintrc.yaml"
  }

  # git
  confirm "link gitconfig file?" && {
    symlink ".gitconfig"
  }

  # mutt
  confirm "link mutt files?" && {
    symlink ".mutt"
  }

  # streamlink
  confirm "link streamlink config file?" && {
    symlink ".streamlinkrc"
  }
  
  # dunst
  confirm "link dunst config file?" && {
    mkdir -vp "$HOME"/.config/dunst
    symlink ".config/dunst/dunstrc"
  }
  
  # i3
  confirm "link i3 files?" && {
    mkdir -vp "$HOME"/.i3
    symlink ".i3/config"
    symlink ".i3/status.conf"
  }
  
  # bin
  confirm "link binary files?" && {
    mkdir -vp "$HOME"/bin
    symlink "bin/extract"
    chmod +x "$HOME"/bin/*
  }

}

# root symlinks
confirm "Install symlinks for ROOT?" && {

  # root folder variable
  # --------------------
  if [[ $OSTYPE = darwin* ]]; then
    rhome="/private/var/root"
  else
    rhome="/root"
  fi
  
  # root dotfiles
  # -------------
  for file in .zshrc .aliases .dircolors .vimrc; do
    sudo ln -sniv "$base"/"$file" "$rhome"/"$file"
  done

}
