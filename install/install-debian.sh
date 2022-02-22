#!/bin/bash

set -e
set -o pipefail

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

# check if running Linux
[[ ! $OSTYPE = linux* ]] && { msg_error "You are not running GNU/linux, exiting."; exit 1; }

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

    msg_info "Adding sid repository to the apt sources..."
    cat <<-EOF > /etc/apt/sources.list
   	deb http://deb.debian.org/debian unstable main contrib non-free
	deb-src http://deb.debian.org/debian unstable main contrib non-free
	EOF

    msg_info "First update of the machine..."
    apt update

    msg_info "First upgrade of the machine..."
    apt upgrade

    msg_info "Doing a final full-upgrade..."
    apt full-upgrade

    apt_clean
}

### Apt common

apt_common() {
    check_is_sudo

    local packages=(
        alsa-utils
        aria2
        bash-completion
        curl
        emacs
        exiftool
        ffmpeg
        git
        imagemagick
        jq
        keepassxc
        mpv
        mu4e
        netcat-openbsd
        obs-studio
        pandoc
        rtorrent
        screenfetch
        shellcheck
        streamlink
        speedtest-cli
        tmux
        torbrowser-launcher
        virt-manager
        xterm
        youtube-dl
    )

    for p in "${packages[@]}"; do
        confirm "Install $p?" && apt install -y "$p"
    done

    local packagesnore=(
        obs-studio
    )

    msg_info "Installing packages with no recommends..."
    for p in "${packagesnore[@]}"; do
        confirm "Install $p?" && apt install -y "$p" --no-install-recommends
    done

    apt_clean
}

install_graphics() {
    check_is_sudo

	local system=$1

	if [[ -z "$system" ]]; then
		echo "You need to specify whether it's intel, geforce or optimus"
		exit 1
	fi

	local pkgs=( xorg xserver-xorg xserver-xorg-input-libinput xserver-xorg-input-synaptics )

	case $system in
		"intel")
			pkgs+=( xserver-xorg-video-intel )
			;;
		"geforce")
			pkgs+=( nvidia-driver )
			;;
		"optimus")
			pkgs+=( nvidia-kernel-dkms bumblebee-nvidia primus )
			;;
		*)
			echo "You need to specify whether it's intel, geforce or optimus"
			exit 1
			;;
	esac

    msg_info "Installing graphics drivers..."
	apt install -y "${pkgs[@]}" --no-install-recommends

    apt_clean
}

### Gnome

set_gnome() {
    check_is_sudo

    local packages=(
        gnome-shell-extension-desktop-icons-ng
        gnome-shell-extension-hide-activities
        gnome-shell-extension-appindicator
        gnome-shell-extension-sound-device-chooser
        gnome-shell-extension-dash-to-panel
    )

    for p in "${packages[@]}"; do
        confirm "Install $p?" && apt install -y "$p"
    done

    apt_clean

    msg_info "Applying custom settings (ignore 'No such schema' errors)..."

    # Files
    gsettings set org.gtk.settings.file-chooser show-hidden true
    gsettings set org.gtk.settings.file-chooser sort-directories-first true
    gsettings set org.gnome.nautilus.preferences show-image-thumbnails always

    # Settings
    gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/gnome/Blobs.svg'
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing

    # Tweaks
    gsettings set org.gnome.desktop.interface enable-animations false
    gsettings set org.gnome.desktop.interface gtk-key-theme Emacs
    gsettings set org.gnome.desktop.peripherals.mouse accel-profile flat
    gsettings set org.gnome.desktop.interface enable-hot-corners false
    gsettings set org.gnome.desktop.interface clock-show-date false
    gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
    gsettings set org.gnome.desktop.input-sources xkb-options [\'caps:ctrl_modifier\']

    # Just Perfection
    gsettings set org.gnome.shell.extensions.just-perfection startup-status 0
    gsettings set org.gnome.shell.extensions.just-perfection panel-size 24
    gsettings set org.gnome.shell.extensions.just-perfection panel-corner-size 1
    gsettings set org.gnome.shell.extensions.just-perfection panel-button-padding-size 5
    gsettings set org.gnome.shell.extensions.just-perfection panel-indicator-padding-size 1

    # Dash to Panel
    gsettings set org.gnome.shell.extensions.dash-to-panel panel-sizes '{"0":24}'
    gsettings set org.gnome.shell.extensions.dash-to-panel appicon-margin 4
    gsettings set org.gnome.shell.extensions.dash-to-panel show-favorites false
    gsettings set org.gnome.shell.extensions.dash-to-panel group-apps false
    gsettings set org.gnome.shell.extensions.dash-to-panel stockgs-keep-top-panel true

    # Desktop Icon NG
    gsettings set org.gnome.shell.extensions.ding show-home true
    gsettings set org.gnome.shell.extensions.ding show-volumes true
    gsettings set org.gnome.shell.extensions.ding show-network-volumes true
    gsettings set org.gnome.shell.extensions.ding show-hidden true

    # Sound & Input Device Chooser
    gsettings set org.gnome.shell.extensions.sound-output-device-chooser show-profiles false
    gsettings set org.gnome.shell.extensions.sound-output-device-chooser show-input-devices false
}

### cwm

set_cwm() {
    check_is_sudo

    local packages=(
        cwm
        sxiv
        tint2
    )

    for p in "${packages[@]}"; do
        confirm "Install $p?" && apt install -y "$p"
    done

    apt_clean
}

### Synology Drive Client

install_driveclient() {
    check_is_sudo

    source="https://global.download.synology.com/download/Utility/SynologyDriveClient/3.0.3-12689/Ubuntu/Installer/x86_64/synology-drive-client-12689.x86_64.deb"
    tmpdir=$(mktemp -d)

    (
        msg_info "Creating temporary folder..."
        cd "$tmpdir" || exit 1

        msg_info "Downloading and installing Synology Drive Client"
        curl -#L "$source" --output sdc.deb
        apt install ./sdc.deb
    )

    msg_info "Deleting temp folder..."
    rm -rf "$tmpdir"
}

### Steam

install_steam() {
    check_is_sudo

    msg_info "Enable i386 architecture for Steam UI"
    dpkg --add-architecture i386

    msg_info "Updating new packages..."
    apt update

    msg_info "Installing additional Nvidia drivers..."
    apt install nvidia-driver-libs:i386 --no-install-recommends

    msg_info "Installing Steam..."
    apt install steam --no-install-recommends

    apt_clean
}

### Signal

install_signalapp() {
    check_is_sudo

    command -v wget >/dev/null 2>&1 || { msg_error "You need wget to continue. Make sure it is installed and in your path."; exit 1; }

    msg_info  "Install official public software signing key"
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

    msg_info "Add our repository to your list of repositories"
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
        tee -a /etc/apt/sources.list.d/signal-xenial.list

    msg_info "Update package database and install signal"
    apt update && apt install signal-desktop
}

### Chatty

install_chatty() {
    check_is_sudo

    command -v jq >/dev/null 2>&1 || { msg_error "You need jq to continue. Make sure it is installed and in your path."; exit 1; }

    # msg_info "Installing java runtime environment..."
    # apt install default-jre

    chatty_latest=$(curl -sSL "https://api.github.com/repos/chatty/chatty/releases/latest" | jq --raw-output .tag_name)
    chatty_latest=${chatty_latest#v}
    repo="https://github.com/chatty/chatty/releases/download/"
    release="v${chatty_latest}/Chatty_${chatty_latest}.zip"

    tmpdir=$(mktemp -d)

    (
        msg_info "Creating temporary folder..."
        cd "$tmpdir" || exit 1

        msg_info "Creating Chatty dir in home folder..."
        mkdir -vp /home/"$SUDO_USER"/.local/bin/Chatty

        msg_info "Downloading and extracting Chatty..."
        curl -#OL "${repo}${release}"
        unzip Chatty_"${chatty_latest}".zip -d /home/"$SUDO_USER"/.local/bin/Chatty
    )

    chown -R "$SUDO_USER":"$SUDO_USER" /home/"$SUDO_USER"/.local/bin/Chatty

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
    echo "  aptsources  (s) - disables translations, updates, upgrades and full-upgrades to testing"
    echo "  aptcommon   (s) - installs few packages"
    echo "  graphics    (s) - installs graphics drivers for X"
    echo "  driveclient (s) - downloads and installs Synology Drive Client"
    echo "  gnome       (s) - installs and sets up Gnome related configs"
    echo "  cwm         (s) - installs and sets up cwm related configs"
    echo "  steam       (s) - enables i386 and installs Steam"
    echo "  signal      (s) - installs the Signal messenger app"
    echo "  chatty      (s) - downloads and installs Chatty with Java runtime environment"

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
    elif [[ $cmd == "aptcommon" ]]; then
        apt_common
    elif [[ $cmd == "graphics" ]]; then
        install_graphics
    elif [[ $cmd == "driveclient" ]]; then
        install_driveclient
    elif [[ $cmd == "gnome" ]]; then
        set_gnome
    elif [[ $cmd == "cwm" ]]; then
        set_cwm
    elif [[ $cmd == "steam" ]]; then
        install_steam
    elif [[ $cmd == "signal" ]]; then
        install_signalapp
    elif [[ $cmd == "chatty" ]]; then
        install_chatty
    else
        usage
    fi
}

main "$@"
