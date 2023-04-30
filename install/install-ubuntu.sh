#!/usr/bin/env bash
set -e
set -u
set -o pipefail
IFS=$'\n\t'

### Recurring functions

msg_info() {
    echo
    printf '\033[33m%s\033[0m\n' "$1"
}

msg_error() {
    printf '\033[91m%s\033[0m\n' "$1" >&2
}

check_is_sudo() {
    [ "$(id -u)" -eq 0 ] || { msg_error "Requires root privileges. Use sudo."; exit 1; }
}

check_is_not_sudo() {
    [ "$(id -u)" -ne 0 ] || { msg_error "Don't run this as sudo."; exit 1; }
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

### Ubuntu OS check

# sourcing /etc/os-release file which contains $ID variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    msg_error "Not running Ubuntu, exiting."
    exit 1
fi

[ "$ID" = ubuntu ] || { msg_error "Not running Ubuntu, exiting."; exit 1; }

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

### Apt common

apt_common() {
    check_is_sudo

    local packages=(
        aria2
        bash-completion
        curl
        exiftool
        ffmpeg
        ffmpegthumbnailer
        git
        imagemagick
        jq
        keepassxc
        mkvtoolnix
        mpv
        pandoc
        shellcheck
        streamlink
        tmux
        virt-manager
        wget
        yt-dlp
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

### snaps

snaps() {
    check_is_sudo

    snap install emacs --classic
    snap install maildir-utils
    snap install steam --beta
}

### Gnome

set_gsettings() {
    check_is_not_sudo

    msg_info "Applying custom settings..."

    # Files (Nautilus)
    dconf write /org/gtk/settings/file-chooser/show-hidden true
    gsettings set org.gnome.nautilus.preferences show-image-thumbnails always

    # Settings
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
    gsettings set org.gnome.shell.app-switcher current-workspace-only true

    # Tweaks
    gsettings set org.gnome.desktop.interface enable-animations false
    gsettings set org.gnome.desktop.interface gtk-key-theme Emacs
    gsettings set org.gnome.desktop.peripherals.mouse accel-profile flat
    gsettings set org.gnome.desktop.interface clock-show-date false
    gsettings set org.gnome.desktop.input-sources xkb-options [\'caps:ctrl_modifier\']

    # Desktop Icon NG
    gsettings set org.gnome.shell.extensions.ding icon-size 'small'
    gsettings set org.gnome.shell.extensions.ding show-home false

    # Ubuntu AppIndicator
    gsettings set org.gnome.shell.extensions.appindicator icon-opacity 255

    msg_info "DON'T FORGET TO SET POWER MODE TO 'PERFORMANCE' IN THE SETTINGS!"
}

### i3wm

set_i3wm() {
    check_is_sudo

    local packages=(
        font-noto
        i3
        network-manager
        # pulseaudio
        sxiv
        xterm
    )

    for p in "${packages[@]}"; do
        confirm "Install $p?" && apt install -y "$p"
    done

    apt_clean
}

### Synology Drive Client

install_driveclient() {
    check_is_sudo

    local source="https://global.download.synology.com/download/Utility/SynologyDriveClient/3.2.0-13238/Ubuntu/Installer/x86_64/synology-drive-client-13238.x86_64.deb"

    local tmpdir
    tmpdir="$(mktemp -d)"

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

### qBittorrent

install_qbittorrent() {
    check_is_sudo

    apt install qbittorrent

    msg_info "Downloading search plugins..."

    sudo -u "$SUDO_USER" bash -c '
    PLUGIN_FOLDER="$HOME/.local/share/qBittorrent/nova3/engines"
    curl --create-dirs -L#o "$PLUGIN_FOLDER/one337x.py" https://gist.githubusercontent.com/BurningMop/fa750daea6d9fa86c8fe5d686f12ed35/raw/16397ff605b1e2f60c70379166c3e7f8df28867d/one337x.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/ettv.py" https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/ettv.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/glotorrents.py" https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/glotorrents.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/kickasstorrents.py" https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/kickasstorrents.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/magnetdl.py" https://scare.ca/dl/qBittorrent/magnetdl.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/linuxtracker.py" https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/6074a7cccb90dfd5c81b7eaddd3138adec7f3377/engines/linuxtracker.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/rutor.py" https://raw.githubusercontent.com/imDMG/qBt_SE/master/engines/rutor.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/tokyotoshokan.py" https://raw.githubusercontent.com/BrunoReX/qBittorrent-Search-Plugin-TokyoToshokan/master/tokyotoshokan.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/torrentdownload.py" https://scare.ca/dl/qBittorrent/torrentdownload.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/torrentgalaxy.py" https://raw.githubusercontent.com/nindogo/qbtSearchScripts/master/torrentgalaxy.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/yts_am.py" https://raw.githubusercontent.com/MaurizioRicci/qBittorrent_search_engine/master/yts_am.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/rutracker.py" https://raw.githubusercontent.com/nbusseneau/qBittorrent-rutracker-plugin/master/rutracker.py
    curl --create-dirs -L#o "$PLUGIN_FOLDER/yggtorrent.py" https://raw.githubusercontent.com/CravateRouge/qBittorrentSearchPlugins/master/yggtorrent.py
    '
}

### Signal

install_signalapp() {
    check_is_sudo

    msg_info  "Install official public software signing key"
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

    msg_info "Add our repository to your list of repositories"
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
        tee -a /etc/apt/sources.list.d/signal-xenial.list

    msg_info "Update package database and install signal"
    apt update && apt install signal-desktop
}

### Veracrypt

install_veracrypt() {
    check_is_sudo

    add-apt-repository ppa:unit193/encryption
    apt update
    apt install veracrypt
}

### Chatty

install_chatty() {
    check_is_sudo

    command -v jq >/dev/null 2>&1 || { msg_error "You need jq to continue. Make sure it is installed and in your path."; exit 1; }

    msg_info "Installing java runtime environment..."
    apt install default-jre

    local chatty_latest
    chatty_latest=$(curl -sSL "https://api.github.com/repos/chatty/chatty/releases/latest" | jq --raw-output .tag_name)
    chatty_latest=${chatty_latest#v}

    local repo="https://github.com/chatty/chatty/releases/download/"
    local release="v${chatty_latest}/Chatty_${chatty_latest}.zip"

    local tmpdir
    tmpdir=$(mktemp -d)

    (
        msg_info "Creating temporary folder..."
        cd "$tmpdir" || exit 1

        msg_info "Creating Chatty dir in home folder..."
        mkdir -vp /opt/Chatty

        msg_info "Downloading and extracting Chatty..."
        curl -#OL "${repo}${release}"
        unzip Chatty_"${chatty_latest}".zip -d /opt/Chatty
    )

    msg_info "Deleting temp folder..."
    rm -rf "$tmpdir"
}

### Tor

install_tor() {
    check_is_sudo

    local distrib
    distrib=$(lsb_release -sc)

    msg_info "Installing apt-transport-https..."
    apt install apt-transport-https -y

    msg_info "Adding Tor Project repository to the apt sources"
    cat <<-EOF > /etc/apt/sources.list.d/tor.list
	deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $distrib main
	deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $distrib main
	EOF

    msg_info "Add the gpg key used to sign the packages"
    wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null

    apt update
    apt install deb.torproject.org-keyring -y
    apt install tor
    apt install torbrowser-launcher
}

### Menu

usage() {
    echo
    printf "Usage:\n"
    printf "  isetup      (s) - passwordless sudo and lock root\n"
    printf "  aptcommon   (s) - installs few packages\n"
    printf "  snaps       (s) - installs few snaps\n"
    printf "  gsettings       - configures Gnome settings\n"
    printf "  i3          (s) - installs and sets up i3wm related configs\n"
    printf "  driveclient (s) - downloads and installs Synology Drive Client\n"
    printf "  qbittorrent (s) - installs qBittorrent and downloads plugins\n"
    printf "  signal      (s) - installs the Signal messenger app\n"
    printf "  veracrypt   (s) - installs VeraCrypt from Unit193's PPA\n"
    printf "  chatty      (s) - downloads and installs Chatty with Java runtime environment\n"
    printf "  tor         (s) - setup Tor Project repository with signatures and installs tor\n"
    echo
}

main() {
    local cmd="${1-}"

    # return error if nothing is specified
    if [ -z "$cmd" ]; then
        usage
        exit 1
    fi

    if [ "$cmd" = "isetup" ]; then
        initial_setup
    elif [ "$cmd" = "aptcommon" ]; then
        apt_common
    elif [ "$cmd" = "snaps" ]; then
        snaps
    elif [ "$cmd" = "gsettings" ]; then
        set_gsettings
    elif [ "$cmd" = "i3" ]; then
        set_i3wm
    elif [ "$cmd" = "driveclient" ]; then
        install_driveclient
    elif [ "$cmd" = "qbittorrent" ]; then
        install_qbittorrent
    elif [ "$cmd" = "signal" ]; then
        install_signalapp
    elif [ "$cmd" = "veracrypt" ]; then
        install_veracrypt
    elif [ "$cmd" = "chatty" ]; then
        install_chatty
    elif [ "$cmd" = "tor" ]; then
        install_tor
    else
        usage
    fi
}

main "$@"
