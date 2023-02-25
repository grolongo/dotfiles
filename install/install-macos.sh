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

### Dotfiles

install_dotfiles() {
    check_is_not_sudo

    [ -e symlinks-unix.sh ] || { msg_error "Please cd into the install directory or make sure symlink-unix.sh is here."; exit 1; }

    msg_info "Launching external symlinks script..."
    ./symlinks-unix.sh
}

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
    defaults write com.apple.dock mineffect -string "scale"
    defaults write com.apple.dock persistent-apps -array
    defaults write com.apple.dock show-recents -bool false
    defaults write com.apple.dock static-only -bool true
    defaults write com.apple.dock launchanim -bool false

    msg_info "Restarting the Dock."
    killall -KILL Dock

    msg_info "Setting Accessibility performance..."
    defaults write com.apple.universalaccess reduceMotion 1
    defaults write com.apple.universalaccess reduceTransparency 1

    msg_info "Setting Terminal prefs..."
    defaults write com.apple.Terminal ShowLineMarks -int 0
    defaults write com.apple.Terminal SecureKeyboardEntry -bool true

    confirm "Some options require reboot to take effect. Reboot now?" && shutdown -r now
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
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
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
        ffmpeg
        gnupg
        jq
        mkvtoolnix
        pandoc
        shellcheck
        speedtest-cli
        streamlink
        tmux
        tor
        yt-dlp
    )

    for p in "${packages[@]}"; do
        confirm "Install $p?" && brew install "$p"
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
        lulu
        mpv
        rectangle
        signal
        silentknight
        spotify
        tor-browser
        veracrypt
    )

    msg_info "Installing cask packages..."
    for p in "${packages[@]}"; do
        confirm "Install $p?" && brew install --cask "$p"
    done

    confirm "Install synology-drive?" &&
        brew tap homebrew/cask-drivers &&
        brew install --cask synology-drive

    echo
    msg_info "Cleaning up install files..."
    brew cleanup
}

### qbittorrent

install_qbittorrent() {
    check_is_not_sudo

    brew install --cask qbittorrent

    local PLUGIN_FOLDER="$HOME/Library/Application Support/qBittorrent/nova3/engines"

    ## RARBG and ThePirateBay should already be installed by default

    msg_info "Downloading search plugins..."
    curl -L#o "$PLUGIN_FOLDER/one337x.py" https://gist.githubusercontent.com/BurningMop/fa750daea6d9fa86c8fe5d686f12ed35/raw/16397ff605b1e2f60c70379166c3e7f8df28867d/one337x.py
    curl -L#o "$PLUGIN_FOLDER/ettv.py" https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/ettv.py
    curl -L#o "$PLUGIN_FOLDER/glotorrents.py" https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/glotorrents.py
    curl -L#o "$PLUGIN_FOLDER/kickasstorrents.py" https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/kickasstorrents.py
    curl -L#o "$PLUGIN_FOLDER/magnetdl.py" https://scare.ca/dl/qBittorrent/magnetdl.py
    curl -L#o "$PLUGIN_FOLDER/linuxtracker.py" https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/6074a7cccb90dfd5c81b7eaddd3138adec7f3377/engines/linuxtracker.py
    curl -L#o "$PLUGIN_FOLDER/rutor.py" https://raw.githubusercontent.com/imDMG/qBt_SE/master/engines/rutor.py
    curl -L#o "$PLUGIN_FOLDER/tokyotoshokan.py" https://raw.githubusercontent.com/BrunoReX/qBittorrent-Search-Plugin-TokyoToshokan/master/tokyotoshokan.py
    curl -L#o "$PLUGIN_FOLDER/torrentdownload.py" https://scare.ca/dl/qBittorrent/torrentdownload.py
    curl -L#o "$PLUGIN_FOLDER/torrentgalaxy.py" https://raw.githubusercontent.com/nindogo/qbtSearchScripts/master/torrentgalaxy.py
    curl -L#o "$PLUGIN_FOLDER/yts_am.py" https://raw.githubusercontent.com/MaurizioRicci/qBittorrent_search_engine/master/yts_am.py
    curl -L#o "$PLUGIN_FOLDER/rutracker.py" https://raw.githubusercontent.com/nbusseneau/qBittorrent-rutracker-plugin/master/rutracker.py
    curl -L#o "$PLUGIN_FOLDER/yggtorrent.py" https://raw.githubusercontent.com/CravateRouge/qBittorrentSearchPlugins/master/yggtorrent.py
}

### Emacs

install_emacs() {
    check_is_not_sudo

    msg_info "Tapping railwaycat/emacsmacport"
    brew tap railwaycat/emacsmacport

    msg_info "Building our Emacs with custom flags..."
    brew install emacs-mac --with-emacs-big-sur-icon --with-starter --with-native-compilation --with-imagemagick --with-mac-metal --with-librsvg --with-xwidgets
}

### Menu

usage() {
    echo
    printf "Usage:\n"
    printf "  dotfiles     - setting up dotfiles\n"
    printf "  prefsettings - setup finder, trackpad, keyboard and dock settings\n"
    printf "  firewall (s) - blocks incoming connection, stealth mode\n"
    printf "  dns          - sets WiFi IPv4 & IPv6 DNS to Cloudflare\n"
    printf "  hostname (s) - changes computer hostname\n"
    printf "  homebrew     - setup homebrew if not installed\n"
    printf "  base         - installs base packages\n"
    printf "  casks        - setup caskroom & installs softwares\n"
    printf "  qbit         - installs qBittorrent with plugins\n"
    printf "  emacs        - building our own Emacs\n"
    echo
}

main() {
    local cmd="${1-}"

    # return error if nothing is specified
    if [ -z "$cmd" ]; then
        usage
        exit 1
    fi

    if [ "$cmd" = "dotfiles" ]; then
        install_dotfiles
    elif [ "$cmd" = "prefsettings" ]; then
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
    elif [ "$cmd" = "qbit" ]; then
        install_qbittorrent
    elif [ "$cmd" = "emacs" ]; then
        install_emacs
    else
        usage
    fi
}

main "$@"
