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

# check if running on raspberrypi
[[ ! $(uname -m) =~ arm ]] && { msg_error "Please run this script on the server."; exit 1; }

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

  read -r -p "What hostname for the machine?: " hostname
  echo "$hostname" > /etc/hostname
  sed -i "s/raspberrypi/$hostname/g" /etc/hosts

  if [ "$SUDO_USER" != "pi" ]; then
    confirm "You're under user '$SUDO_USER'. Do you wish to delete pi?" && {
      deluser --remove-home pi
      groupdel pi
    }
    msg_info "Adding passwordless sudo for $SUDO_USER to /etc/sudoers"
    echo "$SUDO_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    echo
  fi

  msg_info "Disabling root account for security..."
  passwd --delete root
  passwd --lock root

  msg_info "Setting up timezone..."
  dpkg-reconfigure tzdata

  msg_info "Setting up locales..."
  dpkg-reconfigure locales

  msg_info "Changing memory split to 16 for GPU..."
  echo 'gpu_mem=16' >> /boot/config.txt

  msg_info "Expanding filesystem"
  raspi-config --expand-rootfs

  confirm "Disable Bluetooth and WiFi?" && {
    cat <<-EOF > /etc/modprobe.d/raspi-blacklist.conf
		# disable WLAN
		blacklist brcmfmac
		blacklist brcmutil
		blacklist cfg80211
		blacklist rfkill
		# disable bluetooth
		blacklist btbcm
		blacklist hci_uart
		EOF

    systemctl disable hciuart
  }

  msg_info "Reboot now."
}

### Apt base

apt_base() {
    check_is_sudo

    msg_info "Disabling translations to speed-up updates..."
    mkdir -vp /etc/apt/apt.conf.d
    echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/99disable-translations

    msg_info "First update of the machine..."
    apt update

    msg_info "First upgrade of the machine..."
    apt upgrade

    local packages=(
        aria2
        bash-completion
        harden-clients
        harden-servers
        iptables-persistent
        jq
        logwatch
        rng-tools
        tmux
        tor
        vim
    )

    for p in "${packages[@]}"; do
        confirm "Install $p?" && apt install -y "$p"
    done

    apt_clean
}

### Docker

install_docker() {
    check_is_not_sudo

    curl -sSL https://get.docker.com | sh

    msg_info "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"

    confirm "Enable IPv6?" && {
        sudo bash -c 'cat <<-EOF > /etc/docker/daemon.json
        {
        "ipv6": true,
        "fixed-cidr-v6": "2001:db8:1::/64"
        }
        EOF'

        msg_info "Restarting Docker..."
        sudo systemctl restart docker
    }

    confirm "You need to restart to finish. Reboot now?" && {
        sudo reboot
    }
}

### Nextcloud local only (docker)

install_nextcloud_local() {
    check_is_not_sudo
    command -v docker >/dev/null 2>&1 || { msg_error "You need Docker to continue. Make sure it is installed and in your path."; exit 1; }

    local IP
    IP="$(hostname -I | cut -f1 -d ' ')"

    echo
    read -r -p "Enter username for admin account: " ncadmin
    read -r -s -p "Enter password for admin account: " ncpass
    echo

    docker run -d \
           -p 8080:80 \
           -v ncvanilla:/var/www/html \
           -e SQLITE_DATABASE="ncvanilla" \
           -e NEXTCLOUD_ADMIN_USER="${ncadmin}" \
           -e NEXTCLOUD_ADMIN_PASSWORD="${ncpass}" \
           -e NEXTCLOUD_TRUSTED_DOMAINS="${IP}" \
           --restart always \
           --name ncvanilla \
           nextcloud

    msg_info "Waiting for initial install to finish..."
    sleep 180

    msg_info "Disabling unecessary apps..."
    docker exec --user www-data ncvanilla php occ app:disable accessibility
    docker exec --user www-data ncvanilla php occ app:disable systemtags
    docker exec --user www-data ncvanilla php occ app:disable comments
    docker exec --user www-data ncvanilla php occ app:disable federation
    docker exec --user www-data ncvanilla php occ app:disable firstrunwizard
    docker exec --user www-data ncvanilla php occ app:disable nextcloud_announcements
    docker exec --user www-data ncvanilla php occ app:disable survey_client
    docker exec --user www-data ncvanilla php occ app:disable support
    docker exec --user www-data ncvanilla php occ app:disable theming

    msg_info "Enabling and installing some apps..."
    docker exec --user www-data ncvanilla php occ app:enable admin_audit
    docker exec --user www-data ncvanilla php occ app:install limit_login_to_ip
    docker exec --user www-data ncvanilla php occ app:install bruteforcesettings
    docker exec --user www-data ncvanilla php occ app:install notes

    msg_info "Enabling encryption..."
    docker exec --user www-data ncvanilla php occ app:enable encryption
    docker exec --user www-data ncvanilla php occ encryption:enable
    docker exec --user www-data ncvanilla php occ encryption:enable-master-key

    msg_info "Encrypting files..."
    docker exec -it --user www-data ncvanilla php occ encryption:encrypt-all
}

### NextcloudPi internet (docker)

install_nextcloudpi_internet() {
    check_is_not_sudo
    command -v docker >/dev/null 2>&1 || { msg_error "You need Docker to continue. Make sure it is installed and in your path."; exit 1; }

    local IP
    IP="$(hostname -I | cut -f1 -d ' ')"

    docker run -d \
           -p 4443:4443 -p 443:443 -p 80:80 \
           -v ncdata:/data \
           --restart always \
           --name nextcloudpi \
           ownyourbits/nextcloudpi-armhf \
           "$IP"

    echo
    echo "Wait until you see 'init done' with 'docker logs -f nextcloudpi'"
    echo "Then go to (example) https://192.168.1.17 and activate."
    echo "Verify the modem has DynDNS enabled for Let's Encrypt to work in case of dynamic IP."
}

### Seafile

install_seafile() {
    check_is_not_sudo

    command -v jq >/dev/null 2>&1 || { msg_error "You need jq to continue. Make sure it is installed and in your path."; exit 1; }

    sf_latest=$(curl -sSL "https://api.github.com/repos/haiwen/seafile-rpi/releases/latest" | jq --raw-output .tag_name)
    sf_latest=${sf_latest#v}
    repo="https://github.com/haiwen/seafile-rpi/releases/download/"
    release="v${sf_latest}/seafile-server_${sf_latest}_stable_pi.tar.gz"

    tmpdir=$(mktemp -d)

    msg_info "Creating Seafile dir in home..."
    mkdir -vp "$HOME"/Seafile

    (
        msg_info "Creating temporary folder..."
        cd "$tmpdir" || exit 1

        msg_info "Downloading and extracting Seafile ${sf_latest}"
        curl -#L "${repo}${release}" | tar -C "$HOME"/Seafile -xzf -
    )

    msg_info "Deleting temp folder..."
    rm -rf "$tmpdir"

    local packages=(
        python2.7
        libpython2.7
        python-setuptools
        python-imaging
        python-ldap
        python-urllib3
        sqlite3
        python-requests
    )

    msg_info "Installing packages..."
    sudo apt install -y "${packages[@]}"

    (
        cd "$HOME"/Seafile/seafile-server-"$sf_latest" || exit 1
        msg_info "Launching setup script..."
        ./setup-seafile.sh && \
            ./seafile.sh start && \
            ./seahub.sh start
    )

    msg_info "Setting Paris timezone in the config file..."
    echo "TIME_ZONE = 'Europe/Paris'" >> "$HOME"/Seafile/conf/seahub_settings.py

    msg_info "Adding to crontab for autostart on boot..."
    (crontab -l ; echo "@reboot sleep 30 && $HOME/Seafile/seafile-server-latest/seafile.sh start") | crontab -
    (crontab -l ; echo "@reboot sleep 60 && $HOME/Seafile/seafile-server-latest/seahub.sh start") | crontab -
    msg_info "Confirm with 'crontab -l'"

    msg_info "Autoremoving..."
    sudo apt autoremove

    msg_info "Autocleaning..."
    sudo apt autoclean

    msg_info "Cleaning..."
    sudo apt clean
}

### Pihole

install_pihole() {
    check_is_sudo

    msg_info "Installing Pihole..."
    curl -sSL https://install.pi-hole.net | bash

    msg_info "Adding additional blocking lists to /etc/pihole/adlists.list"
    {
        curl -sSL https://v.firebog.net/hosts/lists.php?type=all
        echo https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/CountryCodesLists/EuropeanUnion.txt
        echo https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/CountryCodesLists/France.txt
        echo https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/EasyList-Liste-FR.txt
    } >> /etc/pihole/adlists.list

    msg_info "Adding some urls to whitelist..."

    # android app store
    pihole -w android.clients.google.com

    msg_info "Updating gravity..."
    pihole -g

    echo
    echo "Change DNS addresses on all devices:"
    echo "Either enter twice the same IP of the Pi for DNS1 and DNS2"
    echo "or when you can't, leave DNS2 BLANK! (no 8.8.8.8 or anything else)"
    echo "also don't forget IPv6."
}

### Pihole (docker)

install_pihole_docker() {
    check_is_not_sudo
    command -v docker >/dev/null 2>&1 || { msg_error "You need Docker to continue. Make sure it is installed and in your path."; exit 1; }

    local IP
    IP="$(ip route get 8.8.8.8 | awk '{ print $NF; exit }')"

    local IPv6
    IPv6="$(ip -6 route get 2001:4860:4860::8888 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')"

    echo
    echo "Make sure your IPs are correct, hard code ServerIP ENV VARs if necessary."
    echo
    echo "IPv4: ${IP}"
    echo "IPv6: ${IPv6}"
    echo

    echo
    read -r -p "Do you want to use Pihole as your DHCP server? [y/n] " dockerchoice
    case "$dockerchoice" in
        [yY]es|[yY])
            docker run -d \
                   --name pihole \
                   -p 53:53/tcp -p 53:53/udp \
                   -p 67:67/udp \
                   --cap-add=NET_ADMIN \
                   -p 80:80 \
                   -p 443:443 \
                   -v pihole:/etc/pihole \
                   -v dnsmasq:/etc/dnsmasq.d \
                   -e ServerIP="${IP}" \
                   -e ServerIPv6="${IPv6}" \
                   -e DNS1="1.1.1.1" \
                   -e DNS2="1.0.0.1" \
                   --restart=always \
                   --dns=127.0.0.1 --dns=1.1.1.1 \
                   pihole/pihole:latest
            ;;
        [nN]o|[nN])
            docker run -d \
                   --name pihole \
                   -p 53:53/tcp -p 53:53/udp \
                   -p 80:80 \
                   -p 443:443 \
                   -v pihole:/etc/pihole \
                   -v dnsmasq:/etc/dnsmasq.d \
                   -e ServerIP="${IP}" \
                   -e ServerIPv6="${IPv6}" \
                   -e DNS1="1.1.1.1" \
                   -e DNS2="1.0.0.1" \
                   --restart=always \
                   --dns=127.0.0.1 --dns=1.1.1.1 \
                   pihole/pihole:latest
            ;;
        *)
            echo "You didn't choose yes or no, exiting."
            exit 1
            ;;
    esac

    echo
    until [ "$(docker inspect -f '{{json .State.Health.Status}}' pihole)" == '"healthy"' ]; do
        msg_info "First init not finished yet, waiting 10 seconds more..." && sleep 10;
    done;

    msg_info "Adding additional blocking lists to /etc/pihole/adlists.list"
    docker exec pihole bash -c "{
    curl -sSL https://v.firebog.net/hosts/lists.php?type=all
    echo https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/CountryCodesLists/EuropeanUnion.txt
    echo https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/CountryCodesLists/France.txt
    echo https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/EasyList-Liste-FR.txt
    } >> /etc/pihole/adlists.list"

    msg_info "Adding some urls to whitelist..."
    # android app store
    docker exec pihole pihole -w android.clients.google.com

    msg_info "Updating gravity..."
    docker exec pihole pihole -g

    echo
    echo "Change DNS addresses on all devices:"
    echo "IPv4: ${IP}"
    echo "IPv6: ${IPv6}"
    echo
    echo -n "Your password for https://${IP}/admin/ is "
    docker logs pihole 2> /dev/null | grep 'password:'
}

### Fail2ban

install_fail2ban() {
    check_is_sudo

    command -v jq >/dev/null 2>&1 || { msg_error "You need jq to continue. Make sure it is installed and in your path."; exit 1; }

    f2b_latest=$(curl -sSL "https://api.github.com/repos/fail2ban/fail2ban/releases/latest" | jq --raw-output .tag_name)
    repo="https://github.com/fail2ban/fail2ban/archive/"
    release="${f2b_latest}.tar.gz"

    tmpdir=$(mktemp -d)

    (
        msg_info "Creating temporary folder..."
        cd "$tmpdir" || exit 1

        msg_info "Downloading and extracting ${f2b_latest}"
        curl -#L "${repo}${release}" | tar -xzf -

        cd fail2ban-"${f2b_latest}" || exit 1

        msg_info "Installing..."
        python setup.py install

        msg_info "Moving init file to location..."
        cp files/debian-initd /etc/init.d/fail2ban
    )

    msg_info "Updating the init script..."
    update-rc.d fail2ban defaults

    msg_info "Starting the service..."
    service fail2ban start

    msg_info "Deleting temp folder..."
    rm -rf "$tmpdir"

    echo
    echo "You can now add your own jail.local and filters to /etc/fail2ban"
}

### Msmtp

install_msmtp() {
    check_is_sudo

    local packages=(
        msmtp
        msmtp-mta
        ca-certificates
    )

    apt_install
    apt_clean

    msg_info "Now add custom /etc/msmtprc"
    msg_info "Then try with: 'echo test | msmtp <email recipient>'"
}

### Lynis

install_lynis() {
    check_is_sudo

    msg_info "Importing key to apt..."
    wget -O - https://packages.cisofy.com/keys/cisofy-software-public.key | apt-key add -

    msg_info "Installing https transport if not present..."
    apt install apt-transport-https

    msg_info "Adding Lynis repository to apt sources list..."
    echo 'deb https://packages.cisofy.com/community/lynis/deb/ stable main' > /etc/apt/sources.list.d/cisofy-lynis.list && \
        msg_info "Updating..."
    apt update

    local packages=(
        lynis
    )

    apt_install
    apt_clean
}

### Menu

usage() {
    echo
    echo "This script installs my basic setup for a server."
    echo
    echo "Usage:"
    echo "  dotfiles                          - setup dotfiles from external script"
    echo "  isetup                        (s) - delete pi user, passwordless sudo, lock root and run raspi-config"
    echo "  aptbase                       (s) - disable translations, update, upgrade and installs few packages"
    echo "  docker                            - installs docker"
    echo "  nextcloud_docker_local            - downloads and deploys nextcloudpi with Docker"
    echo "  nextcloudpi_docker_internet       - downloads and deploys nextcloudpi with Docker"
    echo "  seafile                           - downloads and deploys Seafile server"
    echo "  pihole                        (s) - runs Pihole bash script installer"
    echo "  pihole_docker                     - downloads and deploys Pihole with Docker"
    echo "  fail2ban                      (s) - downloads and installs Fail2ban"
    echo "  msmtp                         (s) - installs msmtp and msmtp-mta"
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
        elif [[ $cmd == "aptbase" ]]; then
            apt_base
        elif [[ $cmd == "isetup" ]]; then
            initial_setup
        elif [[ $cmd == "docker" ]]; then
            install_docker
        elif [[ $cmd == "nextcloud_docker_local" ]]; then
            install_nextcloud_local
        elif [[ $cmd == "nextcloudpi_docker_internet" ]]; then
            install_nextcloudpi_internet
        elif [[ $cmd == "seafile" ]]; then
            install_seafile
        elif [[ $cmd == "pihole" ]]; then
            install_pihole
        elif [[ $cmd == "pihole_docker" ]]; then
            install_pihole_docker
        elif [[ $cmd == "fail2ban" ]]; then
            install_fail2ban
        elif [[ $cmd == "msmtp" ]]; then
            install_msmtp
        elif [[ $cmd == "lynis" ]]; then
            install_lynis
        else
            usage
        fi
}

main "$@"
