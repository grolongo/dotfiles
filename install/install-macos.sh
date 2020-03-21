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

### Initial setup

initial_setup() {
  check_is_not_sudo

  msg_info "Updating softwares..."
  softwareupdate -i -a
  
  msg_info "Closing System Preferences to avoid conflicts..."
  osascript -e 'tell application "System Preferences" to quit'

  # Finder
  # ------

  # Show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Display full POSIX path as Finder window title
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Show icons for hard drives, servers, and removable media on the desktop
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

  # Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Disable window animations and Get Info animations
  defaults write com.apple.finder DisableAllAnimations -bool true
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

  # Don't default to saving documents to iCloud
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  msg_info "Restarting Finder..."
  killall -KILL Finder

  # Dock
  # ----
  
  # Show only open applications in the Dock
  defaults write com.apple.dock static-only -bool true
  defaults write ~/Library/Preferences/com.apple.dock.plist show-recents -bool false
  
  # Turn off indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool false

  # Change minimize/maximize window effect
  defaults write com.apple.dock mineffect -string "scale"
  
  msg_info "Restarting the dock..."
  killall -KILL Dock

  # MenuBar
  # -------

  # Show battery percentage
  defaults write com.apple.menuextra.battery ShowPercent true

  msg_info "Restarting the menu bar..."
  killall -KILL SystemUIServer

  # Trackpad and Keyboard
  # ---------------------

  # Trackpad: enable tap to click for this user and for the login screen
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Set a blazingly fast keyboard repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10

  # Appearance
  # ----------

  # Enable dark mode
  defaults write com.apple.universalaccess.plist reduceTransparency -bool true
  defaults write com.apple.universalaccess.plist reduceMotion -bool true
  osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

  confirm "Some options require reboot to take effect. Reboot now?" && sudo shutdown -r now
}

### Network & Security

setup_network_n_sec() {
  check_is_not_sudo

  msg_info "Setting CMD+L to lock screen, Windows like..."
  defaults write -g NSUserKeyEquivalents -dict-add "Lock Screen" -string "@l"

  read -p "Set firmware password? " -n 1 -r firmwarepass
  if [[ $firmwarepass =~ ^[Yy]$ ]]
  then
    sudo firmwarepasswd -setpasswd -setmode full
  fi

  read -p "Change mac hostname/computer name? " -n 1 -r userpass
  if [[ $userpass =~ ^[Yy]$ ]]
  then
    read -r -p "Choose a new name: " newname
    sudo scutil --set ComputerName "$newname"
    sudo scutil --set LocalHostName "$newname"
  fi

  msg_info "Blocking all incoming connections..."
  sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 2

  msg_info "Enabling stealth mode..."
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

  msg_info "Disabling Bonjour multicast advertisements"
  sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES

  msg_info "Disabling crash reporting to Cupertino..."
  defaults write com.apple.CrashReporter DialogType none

  msg_info "Disabling captive portal..."
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false

  msg_info "Enabling APPs hardening..."
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off

  msg_info "Flushing APPs cache..."
  sudo pkill -HUP socketfilterfw

  msg_info "Changing DNS servers to CloudFlare's..."
  networksetup -setdnsservers Wi-Fi 1.0.0.1 2606:4700:4700::1001
  networksetup -setdnsservers "Thunderbolt Ethernet" 1.0.0.1 2606:4700:4700::1001

  msg_info "Flushing DNS cache..."
  sudo killall -HUP mDNSResponder
}

### Homebrew installation

install_homebrew() {
  check_is_not_sudo

  if test ! "$(command -v brew >/dev/null 2>&1)"
  then
    msg_info "Downloading and installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
    coreutils
    dos2unix
    exa
    exiftool
    ffmpeg
    gnupg
    jq
    lynis
    m-cli
    mas
    mpv
    pandoc
    screenfetch
    speedtest-cli
    streamlink
    tldr
    tor
    wifi-password
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

  msg_info "Tapping caskroom/cask"
  brew tap caskroom/cask

  local packages=(
    adobe-acrobat-reader
    adobe-creative-cloud
    dash
    electrum
    emacs
    firefox
    homebrew/cask-fonts/font-iosevka
    iterm2
    keepassxc
    nextcloud
    onionshare
    thunderbird
    tor-browser
    seafile-client
    spotify
    veracrypt
    visual-studio-code
  )

  msg_info "Installing cask packages..."
  for p in "${packages[@]}"; do
    confirm "Install $p?" && brew cask install "$p"
  done

  echo
  msg_info "Cleaning up install files..."
  brew cleanup
}

### Zsh

install_zsh() {
  check_is_not_sudo

  local packages=(
    zsh
    zsh-completions
  )

  brew_install
  brew_clean

  msg_info "Installing Spaceship's prompt..."
  git clone https://github.com/denysdovhan/spaceship-prompt.git "$HOME"/spaceship-prompt
  ln -sfv "$HOME/spaceship-prompt/spaceship.zsh" "/usr/local/share/zsh/site-functions/prompt_spaceship_setup"

  msg_info "Appending brew's zsh path to /etc/shells..."
  checkShell() {
    if [ -d "/usr/local/Cellar/zsh" ]; then
      if ! grep -q "/usr/local/bin/zsh" "/etc/shells"; then
        echo /usr/local/bin/zsh | sudo tee -a /etc/shells && echo "added '/usr/local/Cellar/zsh' to the list of shells"
      fi
    fi
  }

  # zsh for user
  confirm "Default shell to zsh for $USER?" && {
    checkShell; chsh -s "$(command -v zsh)"
  }
  # zsh for root (we keep built-in zsh because we have errors with homebrew's zsh with root)
  echo
  confirm "Default shell to zsh for ROOT?" && {
    sudo chsh -s "/bin/zsh"
  }
}

### Neovim

install_neovim() {
  check_is_not_sudo

  local packages=(
    neovim
    python
    ripgrep
    ruby
    shellcheck
  )

  brew_install
  brew_clean

  msg_info "Setting up python3 providers for deoplete..."
  pip3 install --user --upgrade neovim

  msg_info "Installing vimscript linter..."
  pip3 install --upgrade vim-vint

  msg_info "Installing markdown linter..."
  gem install --user-install mdl
}

### Tmux

install_tmux() {
  check_is_not_sudo

  # check if we are in the correct folder
  [[ -e install-macos.sh ]] || { msg_error "Please cd into the install dir before doing this."; exit 1; }

  local base="${PWD%/*}"

  local packages=(
    tmux
  )

  brew_install
  brew_clean

  msg_info "Compiling fresh terminfo files for italics in tmux..."
  tic -o "$HOME"/.terminfo "$base"/.terminfo/tmux.terminfo
  tic -o "$HOME"/.terminfo "$base"/.terminfo/tmux-256color.terminfo
  tic -o "$HOME"/.terminfo "$base"/.terminfo/xterm-256color.terminfo
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

### Fonts

install_fonts() {
  check_is_not_sudo

  [[ -e install-macos.sh ]] || { msg_error "Please cd into the directory where the install script is."; exit 1; }

  base="${PWD%/*}"
  cp -vr "$base"/fonts/* "$HOME"/Library/Fonts
}

### Dotfiles

install_dotfiles() {
  check_is_not_sudo

  [[ -e symlinks-unix.sh ]] || { msg_error "Please cd into the install directory or make sure symlink-unix.sh is here."; exit 1; }

  msg_info "Launching external symlinks script..."
  ./symlinks-unix.sh
}

### Menu

usage() {
  echo
  echo "This script installs my basic setup for a macOS laptop."
  echo
  echo "Usage:"
  echo "  isetup     - docker, finder and mouse preferences"
  echo "  networksec - docker, finder and mouse preferences"
  echo "  homebrew   - setup homebrew if not installed"
  echo "  base       - installs base packages"
  echo "  casks      - setup caskroom & installs softwares"
  echo "  zsh        - installs zsh as default shell with spaceship's prompt"
  echo "  neovim     - installs neovim and python/linters dependencies"
  echo "  tmux       - installs tmux with italics support"
  echo "  chatty     - downloads and installs chatty with java runtime environment"
  echo "  fonts      - copy fonts"
  echo "  dotfiles   - setup dotfiles"
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
  elif [[ $cmd == "networksec" ]]; then
    setup_network_n_sec
  elif [[ $cmd == "homebrew" ]]; then
    install_homebrew
  elif [[ $cmd == "base" ]]; then
    install_base
  elif [[ $cmd == "zsh" ]]; then
    install_zsh
  elif [[ $cmd == "neovim" ]]; then
    install_neovim
  elif [[ $cmd == "tmux" ]]; then
    install_tmux
  elif [[ $cmd == "casks" ]]; then
    install_casks
  elif [[ $cmd == "chatty" ]]; then
    install_chatty
  elif [[ $cmd == "fonts" ]]; then
    install_fonts
  elif [[ $cmd == "dotfiles" ]]; then
    install_dotfiles
  else
    usage
  fi
}

main "$@"
