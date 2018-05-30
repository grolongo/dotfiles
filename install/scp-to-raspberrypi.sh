#!/bin/bash

# check if we are in the correct folder
[[ -e scp-to-raspberrypi.sh ]] || { echo >&2 "Please cd into the install dir before running this script."; exit 1; }

base="${PWD%/*}"

# yes/no prompt
confirm() {
    read -r -p "$1 [y/N] " choice
    case "$choice" in
      [yY]es|[yY])
        return 0
      ;;
      *)
        return 1
      ;;
    esac
}

echo
echo -n "Enter username: "
read -r user
echo -n "Enter ip address: "
read -r ip
echo -n "Enter port: "
read -r port
echo

confirm "Copy SSH pubkey to $user@$ip on $port?" && {
  ssh-copy-id "$user@$ip"
}

confirm "scp to $user@$ip on port $port?" && {
  # dotfiles
  scp -r -P "$port" "$base"/{.zshrc,.zshenv,.aliases,.dircolors,.functions,.tmux.conf,.rtorrent.rc,.vimrc,.weechat,.msmtprc,.terminfo} "$user@$ip":~
  
  # install script
  scp -P "$port" install-raspberrypi.sh "$user@$ip":~
}
