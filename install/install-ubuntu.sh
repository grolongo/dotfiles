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
        fd-find
        ffmpeg
        ffmpegthumbnailer
        git
        gnome-shell-extension-manager
        imagemagick
        jq
        keepassxc
        mkvtoolnix
        mpv
        pandoc
        ripgrep
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

    confirm "Install Emacs snap?" && { snap install emacs --classic; }
    confirm "Install mu4e snap?" && { snap install maildir-utils; }
    confirm "Install steam snap?" && { snap install steam --beta; }
    confirm "Install chromium snap?" && { snap install chromium; }
    confirm "Install spotify snap?" && { snap install spotify; }

    snap refresh
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
    gsettings set org.gnome.desktop.interface enable-animations false
    gsettings set org.gnome.desktop.interface gtk-key-theme Emacs
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.interface clock-show-date false
    gsettings set org.gnome.desktop.peripherals.mouse accel-profile flat
    gsettings set org.gnome.desktop.input-sources xkb-options [\'caps:ctrl_modifier\']
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
    gsettings set org.gnome.shell.app-switcher current-workspace-only true
    gsettings set org.freedesktop.ibus.panel.emoji hotkey  "@as []" # make C-; available in Emacs

    # Night shift mode
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3500
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 0

    # Desktop Icon NG
    gsettings set org.gnome.shell.extensions.ding icon-size 'small'
    gsettings set org.gnome.shell.extensions.ding show-home false

    # Ubuntu AppIndicator
    gsettings set org.gnome.shell.extensions.appindicator icon-opacity 255
    # Dock
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 36

    msg_info "Installing extra extensions..."
    # find the uuid by visiting the gnome extension page and lookup uuid in the source
    array=( system-monitor@gnome-shell-extensions.gcampax.github.com caffeine@patapon.info )

    for i in "${array[@]}"
    do
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s "${i}" &> /dev/null || true
    done

    msg_info "Applying settings..."

    sleep 5

    # caffeine settings
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas/ set org.gnome.shell.extensions.caffeine show-indicator always
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas/ set org.gnome.shell.extensions.caffeine show-notifications false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas/ set org.gnome.shell.extensions.caffeine show-timer true

    # system monitor settings
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@gnome-shell-extensions.gcampax.github.com set org.gnome.shell.extensions/schemas/ set org.gnome.shell.extensions.system-monitor show-cpu true
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@gnome-shell-extensions.gcampax.github.com set org.gnome.shell.extensions/schemas/ set org.gnome.shell.extensions.system-monitor show-memory true
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@gnome-shell-extensions.gcampax.github.com set org.gnome.shell.extensions/schemas/ set org.gnome.shell.extensions.system-monitor show-swap false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@gnome-shell-extensions.gcampax.github.com set org.gnome.shell.extensions/schemas/ set org.gnome.shell.extensions.system-monitor show-download false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@gnome-shell-extensions.gcampax.github.com set org.gnome.shell.extensions/schemas/ set org.gnome.shell.extensions.system-monitor show-upload false

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

### Emacs

install_emacs() {
    check_is_sudo

    read -r -p "Do you need PureGTK (Wayland only)? [y/n] " choice
    case "$choice" in
        [yY]es|[yY])
            local pgtk="--with-pgtk"
            ;;
        [nN]o|[nN])
            local pgtk="--without-pgtk"
            ;;
        *)
            msg_error "Please enter yes or no."
            ;;
    esac

    msg_info "Checking for source packages repository..."
    if ! grep -q "Types: deb deb-src" /etc/apt/sources.list.d/ubuntu.sources; then
        sed -i 's/Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
        apt update
    fi

    msg_info "Installing all dependencies..."
    apt build-dep emacs

    msg_info "Installing extra dependencies for additional support..."
    apt install libmagickcore-dev libmagick++-dev # imagemagick support
    apt install libwebkit2gtk-4.1-dev # xwidgets support

    (
        msg_info "Downloading Emacs from official website..."
        mkdir ~/git && cd ~/git
        wget -O - https://git.savannah.gnu.org/cgit/emacs.git/snapshot/emacs-29.3.tar.gz | tar -xzv
        cd ~/git/emacs-29.3
        export CC=/usr/bin/gcc-13 CXX=/usr/bin/gcc-13
        ./autogen.sh
        # you can check the available flags with: ./configure --help
        ./configure \
            --prefix=/opt/emacs-29 \
            --without-compress-install \
            --with-native-compilation=aot \
            --with-json \
            --with-tree-sitter \
            --with-imagemagick \
            --with-mailutils \
            --with-xwidgets \
            "$pgtk"
        make -j"$(nproc)"
        make install
    )
}

### Synology Drive Client

install_driveclient() {
    check_is_sudo

    local source="https://global.synologydownload.com/download/Utility/SynologyDriveClient/3.5.0-16084/Ubuntu/Installer/synology-drive-client-16084.x86_64.deb"

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

install_mullvad() {
    check_is_sudo

    local distrib
    distrib=$(lsb_release -sc 2> /dev/null)

    local arch
    arch=$(dpkg --print-architecture)

    msg_info "Downloading Mullvad signing key..."
    curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc

    msg_info "Adding Mullvad repository..."
    cat <<-EOF > /etc/apt/sources.list.d/mullvad.sources
	Types: deb
	URIs: https://repository.mullvad.net/deb/stable
	Suites: $distrib
	Components: main
	Architectures: $arch
	Signed-By: /usr/share/keyrings/mullvad-keyring.asc
	EOF

    msg_info "Update package database and installing Mullvad..."
    apt update
    apt install mullvad-vpn
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

    msg_info  "Downloading Signal signing key..."
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

    msg_info "Adding Signal repository..."
    cat <<-EOF > /etc/apt/sources.list.d/signal-xenial.sources
	Types: deb
	URIs: https://updates.signal.org/desktop/apt
	Suites: xenial
	Components: main
	Architectures: amd64
	Signed-By: /usr/share/keyrings/signal-desktop-keyring.gpg
	EOF

    msg_info "Update package database and installing Signal..."
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
    distrib=$(lsb_release -sc 2> /dev/null)

    msg_info "Installing apt-transport-https..."
    apt install apt-transport-https -y

    msg_info "Add the gpg key used to sign the packages"
    wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null

    msg_info "Adding Tor Project repository..."
    cat <<-EOF > /etc/apt/sources.list.d/tor.sources
	Types: deb deb-src
	URIs: https://deb.torproject.org/torproject.org
	Suites: stable
	Components: main
	Signed-By: /usr/share/keyrings/tor-archive-keyring.gpg
	EOF

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
    printf "  aptcommon   (s) - installs a few packages\n"
    printf "  snaps       (s) - installs a few snaps\n"
    printf "  gsettings       - configures Gnome settings\n"
    printf "  i3          (s) - installs and sets up i3wm related configs\n"
    printf "  emacs       (s) - compile Emacs from tarball\n"
    printf "  driveclient (s) - installs Synology Drive Client\n"
    printf "  mullvad     (s) - installs Mullvad VPN from official repository\n"
    printf "  qbittorrent (s) - installs qBittorrent with plugins\n"
    printf "  signal      (s) - installs Signal messenger from official repository\n"
    printf "  veracrypt   (s) - installs VeraCrypt from Unit193's PPA\n"
    printf "  chatty      (s) - installs Chatty with JRE\n"
    printf "  tor         (s) - install Tor from official repository\n"
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
    elif [ "$cmd" = "emacs" ]; then
        install_emacs
    elif [ "$cmd" = "driveclient" ]; then
        install_driveclient
    elif [ "$cmd" = "mullvad" ]; then
        install_mullvad
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
