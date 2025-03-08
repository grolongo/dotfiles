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
        emacs-lucid
        exiftool
        fd-find
        ffmpeg
        ffmpegthumbnailer
        git
        gnome-shell-extension-manager
        httrack
        imagemagick
        jq
        keepassxc
        mg
        mkvtoolnix
        ncat
        nmap
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

snaps_common() {
    check_is_sudo

    confirm "Install chromium (SNAP)?" && { snap install chromium; snap install chromium-ffmpeg; }
    confirm "Install Emacs (SNAP)?" && { snap install emacs --classic; }
    confirm "Install mu4e (SNAP)?" && { snap install maildir-utils; }
    confirm "Install spotify (SNAP)?" && { snap install spotify; }
    confirm "Install steam (SNAP)?" && { snap install steam --beta; }

    snap refresh
}

### Gnome

set_gsettings() {
    check_is_not_sudo

    msg_info "Applying custom settings..."

    # Files (Nautilus)
    dconf write /org/gtk/settings/file-chooser/show-hidden true
    dconf write /org/gtk/settings/file-chooser/sort-directories-first true
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
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ bold-is-bright true

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
        brightnessctl
        dosfstools
        fonts-noto
        fonts-ubuntu
        i3
        mtools
        pinentry-gtk2
        playerctl
        rxvt-unicode
        ttf-mscorefonts-installer
        ubuntu-drivers-common
        ubuntu-restricted-extras
        ubuntu-restricted-addons
        wireplumber
        xorg
        # pulseaudio
        sxiv
    )

    for p in "${packages[@]}"; do
        confirm "Install ${p}?" && apt install -y "${p}"
    done

    apt_clean

    confirm "Install Firefox (SNAP)?" && { snap install firefox; }
    confirm "Install Network-Manager (SNAP)?" && { snap install network-manager; }

    snap refresh

    msg_info "Adding ourselves to video group in order to use brightnessctl without sudo..."
    usermod -aG video "${SUDO_USER}"
}

### Emacs

install_emacs() {
    check_is_sudo

    local source="https://git.savannah.gnu.org/cgit/emacs.git/snapshot/emacs-30.1.tar.gz"

    local tmpdir
    tmpdir="$(mktemp -d)"

    read -r -p "Compile with PureGTK (Wayland only)? [y/n] " choice
    case "$choice" in
        [yY]es|[yY])
            local pgtk="--with-pgtk"
            ;;
        [nN]o|[nN])
            local pgtk="--with-x-toolkit=lucid"
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
    apt build-dep -y emacs

    (
        msg_info "Creating temporary folder..."
        cd "$tmpdir" || exit 1

        msg_info "Downloading Emacs from official website..."
        mkdir /home/"${SUDO_USER}"/git
        wget -O emacs.tar.gz "$source"
        tar -xzvf emacs.tar.gz --directory /home/"${SUDO_USER}"/git
        mv /home/"${SUDO_USER}"/git/emacs* /home/"${SUDO_USER}"/git/emacs

        cd /home/"${SUDO_USER}"/git/emacs
        export CC=/usr/bin/gcc-13 CXX=/usr/bin/gcc-13

        ./autogen.sh
        # you can check the available flags with: ./configure --help
        ./configure \
            --prefix=/opt/emacs \
            --without-compress-install \
            --with-native-compilation=aot \
            --with-sound=no \
            --with-tree-sitter \
            --without-gsettings \
            "$pgtk"
        make -j"$(nproc)"

        msg_info "Changing ownership..."
        chown -R "${SUDO_USER}":"${SUDO_USER}" /home/"${SUDO_USER}"/git
        make install
    )

    msg_info "Deleting temp folder..."
    rm -rf "$tmpdir"
}

### mpv

install_mpv() {
    check_is_not_sudo

    local MPV_CONFIG_PATH="${HOME}/.config/mpv"
    local tmpdir
    tmpdir=$(mktemp -d)

    msg_info "Installing mpv..."
    sudo apt install -y mpv mpv-mpris

    msg_info "Installing plugins..."

    (
        cd "$tmpdir" || exit 1
        wget -O uosc.zip https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip
        unzip -n uosc.zip -d "${MPV_CONFIG_PATH}"
    )

    wget -O "${MPV_CONFIG_PATH}/scripts/thumbfast.lua" https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua
    wget -O "${MPV_CONFIG_PATH}/scripts/visualizer.lua" https://raw.githubusercontent.com/mfcc64/mpv-scripts/master/visualizer.lua
    wget -O "${MPV_CONFIG_PATH}/scripts/crop.lua" https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/crop.lua
    wget -O "${MPV_CONFIG_PATH}/scripts/encode.lua" https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/encode.lua

    rm -rf "$tmpdir"
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
        wget -O sdc.deb "$source"
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
    install -m 0755 -d /etc/apt/keyrings
    wget -qO- https://repository.mullvad.net/deb/mullvad-keyring.asc | tee /etc/apt/keyrings/mullvad-keyring.asc >/dev/null
    chmod a+r /etc/apt/keyrings/mullvad-keyring.asc

    msg_info "Adding Mullvad repository..."
    cat <<-EOF > /etc/apt/sources.list.d/mullvad.sources
	Types: deb
	URIs: https://repository.mullvad.net/deb/stable
	Architectures: $arch
	Suites: $distrib
	Components: main
	Signed-By: /etc/apt/keyrings/mullvad-keyring.asc
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
    PLUGIN_FOLDER="${HOME}/.local/share/qBittorrent/nova3/engines"
    mkdir -p "$PLUGIN_FOLDER"

    URLs=(
        # official plugins
        https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/eztv.py
        https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/limetorrents.py
        https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/piratebay.py
        https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/solidtorrents.py
        https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torlock.py
        https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torrentproject.py
        https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torrentscsv.py

        # third party plugins
        https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/bitsearch.py
        https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/therarbg.py
        https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/torrentdownloads.py
        https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/ettv.py
        https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/glotorrents.py
        https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/kickasstorrents.py
        https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/snowfl.py
        https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/dodi_repacks.py
        https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/fitgirl_repacks.py
        https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/6074a7cccb90dfd5c81b7eaddd3138adec7f3377/engines/linuxtracker.py
        https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/master/engines/nyaasi.py
        https://scare.ca/dl/qBittorrent/torrentdownload.py
        https://scare.ca/dl/qBittorrent/magnetdl.py
        https://raw.githubusercontent.com/imDMG/qBt_SE/master/engines/rutor.py
        https://raw.githubusercontent.com/nbusseneau/qBittorrent-rutracker-plugin/master/rutracker.py
        https://gist.githubusercontent.com/scadams/56635407b8dfb8f5f7ede6873922ac8b/raw/f654c10468a0b9945bec9bf31e216993c9b7a961/one337x.py
        https://raw.githubusercontent.com/AlaaBrahim/qBitTorrent-animetosho-search-plugin/main/animetosho.py
        https://raw.githubusercontent.com/TuckerWarlock/qbittorrent-search-plugins/main/bt4gprx.com/bt4gprx.py
        https://raw.githubusercontent.com/MarcBresson/cpasbien/master/src/cpasbien.py
        https://raw.githubusercontent.com/nindogo/qbtSearchScripts/master/torrentgalaxy.py
        https://raw.githubusercontent.com/menegop/qbfrench/master/torrent9.py
        https://raw.githubusercontent.com/amongst-us/qbit-plugins/main/yts_mx/yts_mx.py
        https://raw.githubusercontent.com/444995/qbit-search-plugins/main/engines/zooqle.py
        https://raw.githubusercontent.com/CravateRouge/qBittorrentSearchPlugins/master/yggtorrent.py
        )

    # Loop over URLs and download each file
    for url in "${URLs[@]}"; do
        filename=$(basename "$url")
        wget -O "${PLUGIN_FOLDER}/${filename}" "${url}"
    done
    '
}

### Signal

install_signalapp() {
    check_is_sudo

    msg_info  "Downloading Signal signing key..."
    install -m 0755 -d /etc/apt/keyrings
    wget -qO- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor | tee /etc/apt/keyrings/signal-desktop-keyring.gpg > /dev/null
    chmod a+r /etc/apt/keyrings/signal-desktop-keyring.gpg

    msg_info "Adding Signal repository..."
    cat <<-EOF > /etc/apt/sources.list.d/signal-xenial.sources
	Types: deb
	URIs: https://updates.signal.org/desktop/apt
	Architectures: amd64
	Suites: xenial
	Components: main
	Signed-By: /etc/apt/keyrings/signal-desktop-keyring.gpg
	EOF

    msg_info "Update package database and installing Signal..."
    apt update
    apt install signal-desktop
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
    chatty_latest=$(wget -qO- "https://api.github.com/repos/chatty/chatty/releases/latest" | jq --raw-output .tag_name)
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
        wget "${repo}${release}"
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

    local arch
    arch=$(dpkg --print-architecture)

    msg_info "Installing apt-transport-https..."
    apt update
    apt install apt-transport-https -y

    msg_info "Add the gpg key used to sign the packages"
    install -m 0755 -d /etc/apt/keyrings
    wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /etc/apt/keyrings/tor-archive-keyring.gpg > /dev/null
    chmod a+r /etc/apt/keyrings/tor-archive-keyring.gpg

    msg_info "Adding Tor Project repository..."
    cat <<-EOF > /etc/apt/sources.list.d/tor.sources
	Types: deb deb-src
	URIs: https://deb.torproject.org/torproject.org
	Architectures: $arch
	Suites: stable
	Components: main
	Signed-By: /etc/apt/keyrings/tor-archive-keyring.gpg
	EOF

    apt update
    apt install deb.torproject.org-keyring -y

    local packages=(
        tor
        torbrowser-launcher
    )

    for p in "${packages[@]}"; do
        confirm "Install ${p}?" && apt install -y "${p}"
    done
}

### Docker

install_docker() {
    check_is_sudo

    local version
    version="4.30.0"

    local tmpdir
    tmpdir="$(mktemp -d)"

    local distrib
    distrib=$(lsb_release -sc 2> /dev/null)

    local arch
    arch=$(dpkg --print-architecture)

    apt update
    apt install ca-certificates

    msg_info "Add the gpg key used to sign the packages"
    install -m 0755 -d /etc/apt/keyrings
    wget -qO- https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
    chmod a+r /etc/apt/keyrings/docker.asc

    msg_info "Adding Docker repository..."
    cat <<-EOF > /etc/apt/sources.list.d/docker.sources
	Types: deb
	URIs: https://download.docker.com/linux/ubuntu
	Architectures: $arch
	Suites: $distrib
	Components: stable
	Signed-By: /etc/apt/keyrings/docker.asc
	EOF

    apt update

    msg_info "Choose if you want to install Docker for your server or desktop"

    PS3="Select: "

    select lng in Server Desktop
    do
        case "$lng" in
            "Server")
                apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                break;;
            "Desktop")
                (
                    msg_info "Creating temporary folder..."
                    cd "$tmpdir" || exit 1
                    wget https://desktop.docker.com/linux/main/amd64/149282/docker-desktop-"${version}"-amd64.deb
                    apt install ./docker-desktop-"${version}"-amd64.deb
                )

                msg_info "Deleting temp folder..."
                rm -rf "$tmpdir"
                break;;
            *)
                msg_error "Wrong input";;
        esac
    done

}

### Menu

usage() {
    echo
    printf "Usage:\n"
    printf "  isetup      (s) - passwordless sudo and lock root\n"
    printf "  aptcommon   (s) - install a few packages\n"
    printf "  snaps       (s) - install a few snaps\n"
    printf "  gsettings       - configures Gnome settings\n"
    printf "  i3          (s) - install and sets up i3wm related configs\n"
    printf "  emacs       (s) - compile Emacs from tarball\n"
    printf "  mpv             - install mpv with plugins\n"
    printf "  driveclient (s) - install Synology Drive Client\n"
    printf "  mullvad     (s) - install Mullvad VPN from official repository\n"
    printf "  qbittorrent (s) - install qBittorrent with plugins\n"
    printf "  signal      (s) - install Signal messenger from official repository\n"
    printf "  veracrypt   (s) - install VeraCrypt from Unit193's PPA\n"
    printf "  chatty      (s) - install Chatty with JRE\n"
    printf "  tor         (s) - install Tor from official repository\n"
    printf "  docker      (s) - install Docker from official repository\n"
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
        snaps_common
    elif [ "$cmd" = "gsettings" ]; then
        set_gsettings
    elif [ "$cmd" = "i3" ]; then
        set_i3wm
    elif [ "$cmd" = "emacs" ]; then
        install_emacs
    elif [ "$cmd" = "mpv" ]; then
        install_mpv
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
    elif [ "$cmd" = "docker" ]; then
        install_docker
    else
        usage
    fi
}

main "$@"
