#!/bin/bash

# Recurring functions {{{
# ===================
msg_info() {
  yellow='\033[33m'
  nc='\033[0m'
  echo
  echo -e "${yellow}$1${nc}"
}

msg_error() {
  red='\033[91m'
  nc='\033[0m'
  echo -e "${red}$1${nc}" >&2
}

check_is_sudo() {
  if [ "$EUID" -ne 0 ]; then
    msg_error "Requires root privileges. Use sudo."
    exit 1
  fi
}

check_is_not_sudo() {
  if [ ! "$EUID" -ne 0 ]; then
    msg_error "Don't run this as sudo."
    exit 1
  fi
}

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
        msg_error "Please enter yes or no."
      ;;
    esac
  done
}

apt_install() {
  msg_info "Installing packages..."
  apt install -y "${packages[@]}"
}

apt_clean() {
  msg_info "Autoremoving..."
  apt autoremove

  msg_info "Autocleaning..."
  apt autoclean

  msg_info "Cleaning..."
  apt clean
}
# }}}
# check if running WSL
[[ ! $(uname -r) =~ Microsoft ]] && { msg_error "You are not running WSL, exiting."; exit 1; }
# Initial setup {{{
# =============
initial_setup() {
  check_is_sudo

  msg_info "Adding passwordless sudo for $SUDO_USER to /etc/sudoers"
  echo "$SUDO_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  echo

  confirm "Disable ROOT account for security?" && {
    passwd --delete root
    passwd --lock root
  }
}
# }}}
# Apt base {{{
# ========
apt_base() {
  check_is_sudo

  msg_info "Disabling translations to speed-up updates..."
  mkdir -vp /etc/apt/apt.conf.d
  echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/99disable-translations

  msg_info "First update of the machine..."
  apt update

  msg_info "First upgrade of the machine..."
  apt upgrade

  local packages=(
    exiftool
    gnupg2
    harden-clients
    jq
    speedtest-cli
  )

  for p in "${packages[@]}"; do
    confirm "Install $p?" && apt install -y "$p"
  done

  apt_clean
}
# }}}
# Zsh {{{
# ===
install_zsh() {
  check_is_not_sudo

  sudo apt install -y zsh

  msg_info "Installing Spaceship's prompt..."
  git clone https://github.com/denysdovhan/spaceship-prompt.git "$HOME"/spaceship-prompt
  sudo ln -sfv "$HOME/spaceship-prompt/spaceship.zsh" "/usr/local/share/zsh/site-functions/prompt_spaceship_setup"

  # zsh for user
  confirm "Change shell to zsh for $USER?" && {
    chsh -s "/bin/zsh"
  }

  # zsh for root
  confirm "Change shell to zsh for ROOT?" && {
    sudo chsh -s "/bin/zsh"
  }

  apt_clean
}
# }}}
# Neovim {{{
# ======
install_neovim() {
  check_is_not_sudo

  msg_info "Adding neovim ppa..."
  sudo add-apt-repository ppa:neovim-ppa/stable

  msg_info "Updating packages list..."
  sudo apt update

  local packages=(
    neovim
    python3-dev
    python3-pip
    ruby
    shellcheck
  )

  msg_info "Installing neovim with dependencies..."
  sudo apt install -y "${packages[@]}"

  msg_info "Setting up python dependencies..."
  pip3 install --user --upgrade neovim

  msg_info "Installing vimscript linter..."
  pip3 install --user --upgrade vim-vint

  msg_info "Installing markdown linter gem..."
  gem install --user-install mdl

  msg_info "Autoremoving..."
  sudo apt autoremove

  msg_info "Autocleaning..."
  sudo apt autoclean

  msg_info "Cleaning..."
  sudo apt clean
}
# }}}
# Emoji support {{{
# =============
install_emojis() {
  check_is_not_sudo

  win_userprofile="$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)"
  win_userprofile_drive="${win_userprofile%%:*}:"
  userprofile_mount="$(findmnt --noheadings --first-only --output TARGET "$win_userprofile_drive")"
  win_userprofile_dir="${win_userprofile#*:}"
  userprofile="${userprofile_mount}${win_userprofile_dir//\\//}"

  tmpdir=$(mktemp -d)
                                                                                
  (
  msg_info "Creating temporary folder..."
  cd "$tmpdir" || exit 1

  msg_info "Downloading emoji extractor script..."
  curl -sSL -o extractor https://raw.githubusercontent.com/wiki/mintty/mintty/getemojis
  chmod +x extractor
                                                                                
  msg_info "Downloading full emoji list webpage..."
  curl -sSL -o full-emoji-list.html https://www.unicode.org/emoji/charts-11.0/full-emoji-list.html

  msg_info "Extracting Apple set emojis..."
  ./extractor full-emoji-list.html apple
                                                                                
  msg_info "Moving extracted files to their correct location..."
  mv 1 "$userprofile"/AppData/Roaming/wsltty/emojis/apple
  )
                                                                                
  msg_info "Deleting temp folder..."
  rm -rf "$tmpdir"
}
# }}}
# Ripgrep {{{
# =======
install_ripgrep() {
  check_is_not_sudo

  rg_latest=$(curl -sSL "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | jq --raw-output .tag_name)
  repo="https://github.com/BurntSushi/ripgrep/releases/download/"
  release="${rg_latest}/ripgrep-${rg_latest}-x86_64-unknown-linux-musl.tar.gz"

  tmpdir=$(mktemp -d)

  (
  msg_info "Creating temporary folder..."
  cd "$tmpdir" || exit 1

  msg_info "Downloading and extracting Ripgrep ${rg_latest}"
  curl -#L "${repo}${release}" | tar -xzf - --strip-components=1

  msg_info "Moving extracted files to their correct locations..."

  # rg binary
  sudo mv rg /usr/local/bin/

  # rg manual
  sudo mkdir -vp /usr/local/share/man/man1
  sudo mv rg.1 /usr/local/share/man/man1/

  # bash & zsh completions
  sudo mv complete/rg.bash-completion /usr/share/bash-completion/completions/rg
  sudo mv complete/_rg /usr/share/zsh/functions/Completion
  )

  msg_info "Deleting temp folder..."
  rm -rf "$tmpdir"

  msg_info "Rebuilding manual database..."
  mandb
}
# }}}
# Tmux {{{
# ====
install_tmux() {
  check_is_not_sudo

  # check if we are in the correct folder
  [[ -e install-wsl.sh ]] || { echo >&2 "Please cd into the install dir before running."; exit 1; }

  base="${PWD%/*}"
  
  local packages=(
    tmux
  )

  msg_info "Installing packages..."
  sudo apt install -y "${packages[@]}"

  msg_info "Compiling fresh terminfo files fo italics in tmux..."
  tic -o "$HOME"/.terminfo "$base"/.terminfo/tmux.terminfo
  tic -o "$HOME"/.terminfo "$base"/.terminfo/tmux-256color.terminfo
  tic -o "$HOME"/.terminfo "$base"/.terminfo/xterm-256color.terminfo

  msg_info "Autoremoving..."
  sudo apt autoremove

  msg_info "Autocleaning..."
  sudo apt autoclean

  msg_info "Cleaning..."
  sudo apt clean
}  
# }}}
# Tor {{{
# ===
install_tor() {
  check_is_not_sudo

  msg_info "Adding gpg key..."
  gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
	gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

  msg_info "Adding Tor Project repository to apt sources list..."
  sudo sh -c 'echo "deb http://deb.torproject.org/torproject.org xenial main" > /etc/apt/sources.list.d/torproject.list' && \
    msg_info "Updating..."
    sudo apt update

  sudo apt install tor deb.torproject.org-keyring

	msg_info "Autoremoving..."
	sudo apt autoremove
	                           
	msg_info "Autocleaning..."
	sudo apt autoclean
	                           
	msg_info "Cleaning..."
	sudo apt clean
}
# }}}
# Weechat {{{
# =======
install_weechat() {
  check_is_sudo

  msg_info "Installing https transport if not present..."
  apt install apt-transport-https

  msg_info "Adding gpg key..."
  apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 11E9DE8848F2B65222AA75B8D1820DB22A11534E

  msg_info "Adding Weechat repository to apt sources list..."
  echo 'deb https://weechat.org/ubuntu xenial main' > /etc/apt/sources.list.d/weechat.list && \
    msg_info "Updating..."
    apt update

  local packages=(
    weechat-curses
    weechat-plugins
  )

  apt_install
  apt_clean
}
# }}}
# Youtube-dl {{{
# ==========
install_youtubedl() {
  check_is_sudo
  curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
  chmod a+rx /usr/local/bin/youtube-dl
}
# }}}
# Lynis {{{
# =====
install_lynis() {
  check_is_sudo

  msg_info "Importing key to apt..."
  wget -O - https://packages.cisofy.com/keys/cisofy-software-public.key | apt-key add -

  msg_info "Installing https transport if not present..."
  apt install apt-transport-https

  msg_info "Adding Lynis repository to apt sources list..."
  echo 'deb https://packages.cisofy.com/community/lynis/deb/ stable main' > /etc/apt/sources.list.d/cisofy-lynis.list && \
    msg_info "Updating..."
    apt update

  local packages=(
    lynis
  )

  apt_install
  apt_clean
}
# }}}
# Veracrypt {{{
# =========
install_veracrypt() {
  check_is_not_sudo

  echo
  echo "Please go to veracrypt.fr and get the latest version number."
  echo "Example: 1.21"
  read -r -p "Enter version: " vc_latest

  repo="https://launchpad.net/veracrypt/trunk/"
  release="${vc_latest}/+download/veracrypt-${vc_latest}-setup.tar.bz2"

  tmpdir=$(mktemp -d)

  (
  msg_info "Creating temporary folder..."
  cd "$tmpdir" || exit 1

  msg_info "Downloading and extracting VeraCrypt ${vc_latest}"
  curl -#L "${repo}${release}" | tar -xjf -

  msg_info "Installing..."
  ./veracrypt-"${vc_latest}"-setup-console-x64
  )

  msg_info "Deleting temp folder..."
  rm -rf "$tmpdir"
}
# }}}
# Dotfiles {{{
# ========
install_dotfiles() {
  check_is_not_sudo

  [[ -e symlinks-unix.sh ]] || { msg_error "Please cd into the install directory or make sure symlink-unix.sh is here."; exit 1; }

  msg_info "Launching external symlinks script..."
  ./symlinks-unix.sh
}
# }}}
# Menu {{{
# ====
usage() {
  echo
  echo "This script installs my basic setup for a server."
  echo
  echo "Usage:"
  echo "  isetup     - passwordless sudo and lock root"
  echo "  aptbase    - disable translations, update, upgrade and installs few packages"
  echo "  zsh        - installs zsh as default shell and symlinks to root"
  echo "  neovim     - installs neovim with external dependencies, linters and markdown fix"
  echo "  emoji      - downloads apple emoji set to wsltty folder"
  echo "  ripgrep    - downloads and installs ripgrep from github"
  echo "  tmux       - installs tmux and compils profiles for italic support"
	echo "  tor        - adds Tor Project repository with gpg keys and installs Tor"
  echo "  weechat    - setups weechat repository and installs"
  echo "  youtubedl  - downloads youtube-dl and sets permission"
  echo "  lynis      - installs Lynis audit from official repository"
  echo "  veracrypt  - installs VeraCrypt command line"
  echo "  dotfiles   - setup dotfiles from external script"
  echo
}

main() {
  local cmd=$1
  
  # return error if nothing is specified
	if [[ -z "$cmd" ]]; then
    usage
    exit 1
	fi

  if [[ $cmd == "isetup" ]]; then
    initial_setup
  elif [[ $cmd == "aptbase" ]]; then
    apt_base
  elif [[ $cmd == "zsh" ]]; then
    install_zsh
  elif [[ $cmd == "neovim" ]]; then
    install_neovim
  elif [[ $cmd == "emoji" ]]; then
    install_emojis
  elif [[ $cmd == "ripgrep" ]]; then
    install_ripgrep
  elif [[ $cmd == "tmux" ]]; then
    install_tmux
  elif [[ $cmd == "tor" ]]; then
    install_tor
  elif [[ $cmd == "weechat" ]]; then
    install_weechat
  elif [[ $cmd == "youtubedl" ]]; then
    install_youtubedl
  elif [[ $cmd == "lynis" ]]; then
    install_lynis
  elif [[ $cmd == "veracrypt" ]]; then
    install_veracrypt
  elif [[ $cmd == "dotfiles" ]]; then
    install_dotfiles
  else
    usage
  fi
}

main "$@"
# }}}
