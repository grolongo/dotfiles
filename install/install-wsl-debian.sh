#!/bin/bash

### Recurring functions

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

# check if running WSL
[[ ! $(uname -r) =~ Microsoft ]] && { msg_error "You are not running WSL, exiting."; exit 1; }

### Dotfiles

install_dotfiles() {
  check_is_not_sudo

  [[ -e symlinks-unix.sh ]] || { msg_error "Please cd into the install directory or make sure symlink-unix.sh is here."; exit 1; }

  msg_info "Launching external symlinks script..."
  ./symlinks-unix.sh
}

### Initial setup

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

### Apt sources

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

### Apt base

apt_base() {
    check_is_sudo

    local packages=(
        aria2
        bash-completion
        curl
        dos2unix
        exiftool
        ffmpeg
        git
        jq
        man-db
        netcat-openbsd
        pandoc
        rtorrent
        screenfetch
        speedtest-cli
        tldr
        tmux
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

### Veracrypt

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

### Menu

usage() {
    echo
    echo "This script installs my basic setup for a server."
    echo
    echo "Usage:"
    echo "  dotfiles        - setup dotfiles from external script"
    echo "  isetup      (s) - passwordless sudo and lock root"
    echo "  aptsources  (s) - disables translations, updates, upgrades and dist-upgrades to testing"
    echo "  aptbase     (s) - installs few packages"
    echo "  veracrypt       - installs VeraCrypt command line"

    echo
}

main() {
    local cmd=$1

    # return error if nothing is specified
    if [[ -z "$cmd" ]]; then
        usage
        exit 1
    fi

    if [[ $cmd == "dotfiles" ]]; then
        install_dotfiles
    elif [[ $cmd == "isetup" ]]; then
        initial_setup
    elif [[ $cmd == "aptsources" ]]; then
        apt_sources
    elif [[ $cmd == "aptbase" ]]; then
        apt_base
    elif [[ $cmd == "veracrypt" ]]; then
        install_veracrypt
    else
        usage
    fi
}

main "$@"
