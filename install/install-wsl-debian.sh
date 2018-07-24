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
# Apt sources {{{
# ===========
apt_sources() {
  check_is_sudo

  msg_info "Disabling translations to speed-up updates..."
  mkdir -vp /etc/apt/apt.conf.d
  echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/99disable-translations
  
  msg_info "Adding testing repository to the apt sources..."
  cat <<-EOF > /etc/apt/sources.list
	deb http://deb.debian.org/debian testing main contrib non-free
	deb-src http://deb.debian.org/debian testing main contrib non-free

	deb http://deb.debian.org/debian testing-updates main contrib non-free
	deb-src http://deb.debian.org/debian testing-updates main contrib non-free

	deb http://security.debian.org/debian-security/ testing/updates main contrib non-free
	deb-src http://security.debian.org/debian-security/ testing/updates main contrib non-free
	EOF

  msg_info "First update of the machine..."
  apt update

  msg_info "First upgrade of the machine..."
  apt upgrade

  msg_info "doing a final dist-upgrade..."
  apt dist-upgrade

  apt_clean
}
# }}}
# Apt base {{{
# ========
apt_base() {
  check_is_sudo

  local packages=(
    aria2
    curl
    exiftool
    git
    jq
    man-db
    netcat-openbsd
    pandoc
    rtorrent
    screenfetch
    speedtest-cli
    tldr
    tor
    weechat
    weechat-plugins
    weechat-scripts
  )

  for p in "${packages[@]}"; do
    confirm "Install $p?" && apt install -y "$p"
  done

  local packagesnore=(
    youtube-dl
  )

  msg_info "Installing packages with no recommends..."
  for p in "${packagesnore[@]}"; do
    confirm "Install $p?" && apt install -y "$p" --no-install-recommends
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

  msg_info "Autoremoving..."
  sudo apt autoremove

  msg_info "Autocleaning..."
  sudo apt autoclean

  msg_info "Cleaning..."
  sudo apt clean
}
# }}}
# Neovim {{{
# ======
install_neovim() {
  check_is_not_sudo

  local packages=(
    git
    neovim
    python3-neovim
    python3-pip
    python3-setuptools
    ruby
    shellcheck
  )

  msg_info "Installing neovim with dependencies..."
  sudo apt install -y "${packages[@]}" --no-install-recommends

  msg_info "Setting up wheel..."
  pip3 install --user --upgrade wheel

  msg_info "Setting up python2 and python3 providers..."
  pip3 install --user --upgrade neovim

  msg_info "Installing vimscript linter..."
  pip3 install --upgrade vim-vint

  msg_info "Installing markdown linter..."
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
  sudo mv doc/rg.1 /usr/local/share/man/man1/

  # bash & zsh completions
  sudo mv complete/rg.bash /usr/share/bash-completion/completions/rg
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
  [[ -e install-wsl-debian.sh ]] || { echo >&2 "Please cd into the install dir before running."; exit 1; }

  local base="${PWD%/*}"
  
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
  echo "  isetup      (s) - passwordless sudo and lock root"
  echo "  aptsources  (s) - disables translations, updates, upgrades and dist-upgrades to testing"
  echo "  aptbase     (s) - installs few packages"
  echo "  zsh             - installs zsh as default shell and symlinks to root"
  echo "  neovim          - installs neovim with external dependencies, linters and markdown fix"
  echo "  emoji           - downloads apple emoji set to wsltty folder"
  echo "  ripgrep         - downloads and installs ripgrep from github"
  echo "  tmux            - installs tmux and compils profiles for italic support"
  echo "  veracrypt       - installs VeraCrypt command line"
  echo "  dotfiles        - setup dotfiles from external script"
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
  elif [[ $cmd == "aptsources" ]]; then
    apt_sources
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
