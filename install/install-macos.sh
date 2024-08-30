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

brew_install() {
    msg_info "Installing packages..."
    brew install "${packages[@]}"
}

brew_clean() {
    msg_info "Cleaning up install files..."
    brew cleanup
}

# check if running macOS
[ "$(uname)" = Darwin ] || { msg_error "You are not running macOS, exiting."; exit 1; }

### macOS preferences settings

setup_prefsettings() {
    check_is_not_sudo

    msg_info "Closing System Preferences to avoid conflicts..."
    osascript -e 'tell application "System Preferences" to quit'

    msg_info "Setting Finder prefs..."

    # show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # show all files extensions
    defaults write com.apple.finder AppleShowAllExtensions -bool true

    msg_info "Setting trackpad and keyboard..."

    # Trackpad: enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Keyboard: fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    msg_info "Setting Dock prefs..."
    defaults write com.apple.dock orientation left
    defaults write com.apple.dock tilesize -integer 40
    defaults write com.apple.dock mineffect -string "scale"
    defaults write com.apple.dock persistent-apps -array
    defaults write com.apple.dock show-recents -bool false
    defaults write com.apple.dock static-only -bool true
    defaults write com.apple.dock launchanim -bool false

    msg_info "Restarting the Dock."
    killall -KILL Dock

    msg_info "Setting Terminal prefs..."
    defaults write com.apple.Terminal SecureKeyboardEntry -bool true

    confirm "Some options require reboot to take effect. Reboot now?" && sudo shutdown -r now
}

### Firewall

setup_firewall() {
    check_is_sudo

    msg_info "Blocking all incoming connections..."
    defaults write /Library/Preferences/com.apple.alf globalstate -int 2

    msg_info "Enabling stealth mode..."
    /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
}

### DNS

setup_dns() {
    check_is_not_sudo

    msg_info "Setting DNS to Cloudflare..."
    networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001

    msg_info "Flushing DNS cache..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
}

### Hostname

change_hostname() {
    check_is_sudo

    read -r -p "Enter a new name: " newname
    scutil --set ComputerName "$newname"
    scutil --set LocalHostName "$newname"
    scutil --set HostName "$newname"
}

### Homebrew installation

install_homebrew() {
    check_is_not_sudo

    if test ! "$(command -v brew >/dev/null 2>&1)"
    then
        msg_info "Downloading and installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        msg_error "Homebrew is already installed, exiting."
    fi

    msg_info "Turning analytics off..."
    brew analytics off
}

### Brew formulaes

install_base() {
    check_is_not_sudo

    msg_info "Initial update..."
    brew update

    msg_info "Initial ugrade..."
    brew upgrade

    local packages=(
        aria2
        exiftool
        fd
        ffmpeg
        gnupg
        httrack
        imagemagick
        jq
        mkvtoolnix
        nmap
        pandoc
        pinentry-mac
        shellcheck
        speedtest-cli
        streamlink
        tmux
        tor
        wget
        yt-dlp
    )

    for p in "${packages[@]}"; do
        confirm "Install ${p}?" && brew install "${p}"
    done

    brew_clean
}

### Brew casks

install_casks() {
    check_is_not_sudo

    local packages=(
        adobe-creative-cloud
        caffeine
        chatty
        electrum
        firefox
        keepassxc
        knockknock
        lulu
        mullvadvpn
        rectangle
        signal
        silentknight
        spotify
        synology-drive
        tor-browser
        veracrypt
    )

    msg_info "Installing cask packages..."
    for p in "${packages[@]}"; do
        confirm "Install ${p}?" && brew install --cask "${p}"
    done

    echo
    msg_info "Cleaning up install files..."
    brew cleanup
}

### mpv

install_mpv() {
    check_is_not_sudo

    local MPV_CONFIG_PATH="${HOME}/.config/mpv"
    local tmpdir
    tmpdir=$(mktemp -d)

    msg_info "Installing mpv..."
    brew install --cask mpv

    msg_info "Installing plugins..."

    (
        cd "$tmpdir" || exit 1
        curl -L#o uosc.zip https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip
        unzip -n uosc.zip -d "${MPV_CONFIG_PATH}"
    )

    curl -L#o "${MPV_CONFIG_PATH}/scripts/thumbfast.lua" https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua
    curl -L#o "${MPV_CONFIG_PATH}/scripts/visualizer.lua" https://raw.githubusercontent.com/mfcc64/mpv-scripts/master/visualizer.lua
    curl -L#o "${MPV_CONFIG_PATH}/scripts/crop.lua" https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/crop.lua
    curl -L#o "${MPV_CONFIG_PATH}/scripts/encode.lua" https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/encode.lua

    rm -rf "$tmpdir"
}


### qbittorrent

install_qbittorrent() {
    check_is_not_sudo

    brew install --cask qbittorrent

    msg_info "Waiting 10 secs for folders to be made..."
    sleep 10

    local PLUGIN_FOLDER="${HOME}/Library/Application Support/qBittorrent/nova3/engines"

    msg_info "Downloading search plugins..."

    curl -L#o "${PLUGIN_FOLDER}/bitsearch.py"        https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/bitsearch.py
    curl -L#o "${PLUGIN_FOLDER}/therarbg.py"         https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/therarbg.py
    curl -L#o "${PLUGIN_FOLDER}/solidtorrents.py"    https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/solidtorrents.py
    curl -L#o "${PLUGIN_FOLDER}/torrentdownloads.py" https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/torrentdownloads.py
    curl -L#o "${PLUGIN_FOLDER}/ettv.py"             https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/ettv.py
    curl -L#o "${PLUGIN_FOLDER}/glotorrents.py"      https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/glotorrents.py
    curl -L#o "${PLUGIN_FOLDER}/kickasstorrents.py"  https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/kickasstorrents.py
    curl -L#o "${PLUGIN_FOLDER}/snowfl.py"           https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/snowfl.py
    curl -L#o "${PLUGIN_FOLDER}/dodi_repacks.py"     https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/dodi_repacks.py
    curl -L#o "${PLUGIN_FOLDER}/fitgirl_repacks.py"  https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/fitgirl_repacks.py
    curl -L#o "${PLUGIN_FOLDER}/linuxtracker.py"     https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/6074a7cccb90dfd5c81b7eaddd3138adec7f3377/engines/linuxtracker.py
    curl -L#o "${PLUGIN_FOLDER}/nyaasi.py"           https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/master/engines/nyaasi.py
    curl -L#o "${PLUGIN_FOLDER}/torrentdownload.py"  https://scare.ca/dl/qBittorrent/torrentdownload.py
    curl -L#o "${PLUGIN_FOLDER}/magnetdl.py"         https://scare.ca/dl/qBittorrent/magnetdl.py
    curl -L#o "${PLUGIN_FOLDER}/rutor.py"            https://raw.githubusercontent.com/imDMG/qBt_SE/master/engines/rutor.py
    curl -L#o "${PLUGIN_FOLDER}/rutracker.py"        https://raw.githubusercontent.com/imDMG/qBt_SE/master/engines/rutracker.py
    curl -L#o "${PLUGIN_FOLDER}/rutracker2.py"       https://raw.githubusercontent.com/nbusseneau/qBittorrent-rutracker-plugin/master/rutracker.py
    curl -L#o "${PLUGIN_FOLDER}/one337.py"           https://gist.githubusercontent.com/scadams/56635407b8dfb8f5f7ede6873922ac8b/raw/f654c10468a0b9945bec9bf31e216993c9b7a961/one337x.py
    curl -L#o "${PLUGIN_FOLDER}/animetosho.py"       https://raw.githubusercontent.com/AlaaBrahim/qBitTorrent-animetosho-search-plugin/main/animetosho.py
    curl -L#o "${PLUGIN_FOLDER}/bt4gprx.py"          https://raw.githubusercontent.com/TuckerWarlock/qbittorrent-search-plugins/main/bt4gprx.com/bt4gprx.py
    curl -L#o "${PLUGIN_FOLDER}/cpasbien.py"         https://raw.githubusercontent.com/MarcBresson/cpasbien/master/src/cpasbien.py
    curl -L#o "${PLUGIN_FOLDER}/tokyotoshokan.py"    https://raw.githubusercontent.com/BrunoReX/qBittorrent-Search-Plugin-TokyoToshokan/master/tokyotoshokan.py
    curl -L#o "${PLUGIN_FOLDER}/torrentgalaxy.py"    https://raw.githubusercontent.com/nindogo/qbtSearchScripts/master/torrentgalaxy.py
    curl -L#o "${PLUGIN_FOLDER}/torrent9.py"         https://raw.githubusercontent.com/menegop/qbfrench/master/torrent9.py
    curl -L#o "${PLUGIN_FOLDER}/yts_mx.py"           https://raw.githubusercontent.com/amongst-us/qbit-plugins/main/yts_mx/yts_mx.py
    curl -L#o "${PLUGIN_FOLDER}/zooqle.py"           https://raw.githubusercontent.com/444995/qbit-search-plugins/main/engines/zooqle.py
    curl -L#o "${PLUGIN_FOLDER}/yggtorrent.py"       https://raw.githubusercontent.com/CravateRouge/qBittorrentSearchPlugins/master/yggtorrent.py
}

### Emacs

install_emacs() {
    check_is_not_sudo

    msg_info "Tapping railwaycat/emacsmacport"
    brew tap railwaycat/emacsmacport

    msg_info "Building our Emacs with custom flags..."
    brew install emacs-mac --with-emacs-big-sur-icon --with-starter --with-native-compilation --with-imagemagick --with-mac-metal --with-librsvg --with-xwidgets

    msg_info "Making GUI helper to Applications..."
    cp -a "$(brew --prefix)"/opt/emacs-mac/Emacs.app /Applications
}

### MacPorts

install_macports() {
    check_is_not_sudo

    command -v jq >/dev/null 2>&1 || { msg_error "You need jq to continue. Make sure it is installed and in your path."; exit 1; }

    get_macos_version() {
        sw_vers | awk '/ProductVersion/ {
        split($2, a, ".");
        if (a[1] == 10) {
           print a[1] "." a[2];
        } else {
          print a[1];
        }
        }'
    }

    local os_version
    os_version=$(get_macos_version)

    local os_marketing
    os_marketing=$(awk '/SOFTWARE LICENSE AGREEMENT FOR macOS/' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf' | awk -F 'macOS ' '{print $NF}' | awk '{print substr($0, 0, length($0)-1)}')

    local macports_latest
    macports_latest=$(curl -sSL "https://api.github.com/repos/macports/macports-base/releases/latest" | jq --raw-output .tag_name)
    macports_latest=${macports_latest#v}

    local repo="https://github.com/macports/macports-base/releases/download/"
    local release="v${macports_latest}/MacPorts-${macports_latest}-${os_version}-${os_marketing}.pkg"

    local tmpdir
    tmpdir=$(mktemp -d)

    (
        msg_info "Creating temporary folder..."
        cd "$tmpdir" || exit 1

        msg_info "Downloading MacPorts..."
        curl -#OL "${repo}${release}"
        open ./"MacPorts-${macports_latest}-${os_version}-${os_marketing}.pkg"
    )

    confirm "Confirm to delete install file. Please wait for install to finish before deleting." && rm -rf "$tmpdir"
}

install_ports() {
    check_is_sudo

    local packages=(
        aria2
        exiftool
        fd
        ffmpeg
        gnupg2
        httrack
        imagemagick
        jq
        keepassxc
        mkvtoolnix
        mpv
        nmap
        pandoc
        pinentry-mac
        shellcheck
        silentknight
        speedtest-cli
        streamlink
        tmux
        tor
        wget
        yt-dlp
    )

    for p in "${packages[@]}"; do
        confirm "Install ${p}?" && sudo port install "${p}"
    done

    confirm "Install emacs?" && sudo port install emacs +imagemagick +nativecomp +treesitter +xwidgets

}

### Menu

usage() {
    echo
    printf "Usage:\n"
    printf "  prefsettings - setup finder, trackpad, keyboard and dock settings\n"
    printf "  firewall (s) - blocks incoming connection, stealth mode\n"
    printf "  dns          - sets WiFi IPv4 & IPv6 DNS to Cloudflare\n"
    printf "  hostname (s) - changes computer hostname\n"
    printf "  homebrew     - setup homebrew if not installed\n"
    printf "  base         - installs base packages\n"
    printf "  casks        - setup caskroom & installs softwares\n"
    printf "  mpv          - installs mpv with plugins\n"
    printf "  qbit         - installs qBittorrent with plugins\n"
    printf "  emacs        - building our own Emacs\n"
    printf "  macports     - setup MacPorts\n"
    printf "  ports    (s) - installs ports\n"
    echo
}

main() {
    local cmd="${1-}"

    # return error if nothing is specified
    if [ -z "$cmd" ]; then
        usage
        exit 1
    fi

    if [ "$cmd" = "prefsettings" ]; then
        setup_prefsettings
    elif [ "$cmd" = "firewall" ]; then
        setup_firewall
    elif [ "$cmd" = "dns" ]; then
        setup_dns
    elif [ "$cmd" = "hostname" ]; then
        change_hostname
    elif [ "$cmd" = "homebrew" ]; then
        install_homebrew
    elif [ "$cmd" = "base" ]; then
        install_base
    elif [ "$cmd" = "casks" ]; then
        install_casks
    elif [ "$cmd" = "mpv" ]; then
        install_mpv
    elif [ "$cmd" = "qbit" ]; then
        install_qbittorrent
    elif [ "$cmd" = "emacs" ]; then
        install_emacs
    elif [ "$cmd" = "macports" ]; then
        install_macports
    elif [ "$cmd" = "ports" ]; then
        install_ports
    else
        usage
    fi
}

main "$@"
