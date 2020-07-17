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

brew_install() {
    msg_info "Installing packages..."
    brew install "${packages[@]}"
}

brew_clean() {
    msg_info "Cleaning up install files..."
    brew cleanup
}

# check if running macOS
[[ ! $OSTYPE = darwin* ]] && { msg_error "You are not running macOS, exiting."; exit 1; }

### Dotfiles

install_dotfiles() {
    check_is_not_sudo

    [[ -e symlinks-unix.sh ]] || { msg_error "Please cd into the install directory or make sure symlink-unix.sh is here."; exit 1; }

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

    # scale window effect
    defaults write com.apple.dock mineffect -string "scale"

    # remove defaults apps from the dock
    defaults write com.apple.dock persistent-apps -array

    # don't show recent apps in the dock
    defaults write com.apple.dock show-recents -bool false

    # only show active apps in the dock
    defaults write com.apple.dock static-only -bool true

    msg_info "Restarting the Dock."
    killall -KILL Dock

    msg_info "Setting Terminal prefs..."

    # hide line marks
    defaults write com.apple.Terminal ShowLineMarks -int 0

    # enable secure keyboard entry
    defaults write com.apple.Terminal SecureKeyboardEntry -bool true

    confirm "Some options require reboot to take effect. Reboot now?" && shutdown -r now
}

### Firewall & DNS

setup_firewall() {
    check_is_sudo

    msg_info "Blocking all incoming connections..."
    defaults write /Library/Preferences/com.apple.alf globalstate -int 2

    msg_info "Enabling stealth mode..."
    /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

    msg_info "Changing DNS servers to CloudFlare's..."
    networksetup -setdnsservers Wi-Fi 1.0.0.1 2606:4700:4700::1001
    networksetup -setdnsservers "Thunderbolt Ethernet" 1.0.0.1 2606:4700:4700::1001
    
    msg_info "Flushing DNS cache..."
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

### Brew packages

install_base() {
    check_is_not_sudo

    msg_info "Initial update..."
    brew update

    msg_info "Initial ugrade..."
    brew upgrade

    local packages=(
        aria2
        dos2unix
        exiftool
        ffmpeg
        gnupg
        jq
        lynis
        m-cli
        mpv
        pandoc
        shellcheck
        speedtest-cli
        streamlink
        tmux
        tor
        youtube-dl
    )

    for p in "${packages[@]}"; do
        confirm "Install $p?" && brew install "$p"
    done

    brew_clean
}

### Casks

install_casks() {
    check_is_not_sudo

    local packages=(
        adobe-creative-cloud
        electrum
        emacs
        firefox
        keepassxc
        nextcloud
        onionshare
        signal
        thunderbird
        tor-browser
        spotify
        veracrypt
    )

    msg_info "Installing cask packages..."
    for p in "${packages[@]}"; do
        confirm "Install $p?" && brew cask install "$p"
    done

    confirm "Install synology-drive?" &&
        brew tap homebrew/cask-drivers &&
        brew cask install synology-drive

    echo
    msg_info "Cleaning up install files..."
    brew cleanup
}

### Chatty

install_chatty() {
    check_is_not_sudo

    command -v jq >/dev/null 2>&1 || { msg_error "You need jq to continue. Make sure it is installed and in your path."; exit 1; }

    msg_info "Tapping caskroom/cask"
    brew tap caskroom/cask

    msg_info "Installing java runtime environment..."
    brew cask install java

    chatty_latest=$(curl -sSL "https://api.github.com/repos/chatty/chatty/releases/latest" | jq --raw-output .tag_name)
    chatty_latest=${chatty_latest#v}
    repo="https://github.com/chatty/chatty/releases/download/"
    release="v${chatty_latest}/Chatty_${chatty_latest}.zip"

    tmpdir=$(mktemp -d)

    (
        msg_info "Creating temporary folder..."
        cd "$tmpdir" || exit 1

        msg_info "Creating Chatty dir in home folder..."
        mkdir -vp "$HOME"/Chatty

        msg_info "Downloading and extracting Chatty..."
        curl -#OL "${repo}${release}"
        unzip Chatty_"${chatty_latest}".zip -d "$HOME"/Chatty
    )

    msg_info "Deleting temp folder..."
    rm -rf "$tmpdir"

    msg_info "Installing malgun fallback font for special characters..."
    [[ -e install-macos.sh ]] || { msg_error "Please cd into the directory where the install script is."; exit 1; }

    base="${PWD%/*}"
    cp -vr "$base"/.chatty/malgun.ttf "$HOME"/Library/Fonts
}

### Menu

usage() {
    echo
    echo "This script installs my basic setup for a macOS laptop."
    echo
    echo "Usage:"
    echo "  dotfiles     - setup dotfiles"
    echo "  prefsettings - setup finder, trackpad, keyboard and dock settings"
    echo "  firewall (s) - blocks incoming connection, stealth mode"
    echo "  hostname (s) - changes computer hostname"
    echo "  homebrew     - setup homebrew if not installed"
    echo "  base         - installs base packages"
    echo "  casks        - setup caskroom & installs softwares"
    echo "  chatty       - downloads and installs chatty with java runtime environment"
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
    elif [[ $cmd == "prefsettings" ]]; then
        setup_prefsettings
    elif [[ $cmd == "firewall" ]]; then
        setup_firewall
    elif [[ $cmd == "hostname" ]]; then
        change_hostname
    elif [[ $cmd == "homebrew" ]]; then
        install_homebrew
    elif [[ $cmd == "base" ]]; then
        install_base
    elif [[ $cmd == "casks" ]]; then
        install_casks
    elif [[ $cmd == "chatty" ]]; then
        install_chatty
    else
        usage
    fi
}

main "$@"
