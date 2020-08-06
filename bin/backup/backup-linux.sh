#!/bin/bash

# check if running compatible OS
[[ $OSTYPE = linux* ]] || { echo >&2 "You are not running Linux. Exiting."; exit 1; }

### Compression
compress_backup () {
    read -r -e -p "Enter sync folder path: " syncpath

    tmpdir=$(mktemp -d)
    tarfile="$tmpdir"/backup.tar.gz

    echo "Creating tar file..."
    tar --create --gunzip --file "$tarfile" \
        --exclude="Music" \
        --exclude=".seafile-data" \
        --exclude="seafile-data" \
        --exclude="vz" \
        --exclude="Desktop.ini" \
        --exclude=".git" \
        --exclude=".DS_Store" \
        --exclude=".SynologyWorkingDirectory" \
        -C "$syncpath" . \
        -C "$HOME" dotfiles
}

### Cryptsetup
cryptsetup_backup() {
    backup_container="$HOME"/backup.luks
    mnt_folder=/mnt/luksvol
    vol_name=backup

    echo "Creating container at '$backup_container'"
    fallocate -l 500M "$backup_container"

    sleep 5

    echo "Encrypting file..."
    sudo cryptsetup -v --type LUKS \
         --cipher aes-xts-plain64 \
         --key-size 512 \
         --hash sha512 \
         luksFormat "$backup_container"

    sleep 5

    echo "Making the filesystem..."
    sudo cryptsetup luksOpen "$backup_container" "$vol_name"
    mkfs.vfat -F 32 /dev/mapper/"$vol_name"

    sleep 5

    echo "Mounting the device..."
    mkdir -vp "$mnt_folder"
    mount /dev/mapper/"$vol_name" "$mnt_folder"

    sleep 5

    echo "Copying files..."
    cp -v "$HOME"/Downloads/fooc.txt "$mnt_folder"

    sleep 5

    echo "Closing container..."
    umount "$mnt_folder"
    sudo cryptsetup luksClose "$vol_name"
    rm -rf "$mnt_folder"
}

### GPG
gnupg_backup() {
    gpg_backup="$HOME"/backup.tar.gz.gpg

    compress_backup

    echo "Encrypting tar file..."
    gpg --s2k-mode 3 \
        --s2k-cipher-algo AES256 \
        --s2k-digest-algo SHA512 \
        --s2k-count 65000000 \
        --pinentry-mode=ask \
        --output "$gpg_backup" \
        --symmetric "$tarfile"

    echo "Deleting temp folder..."
    rm -rf "$tmpdir"

    echo "Backup file saved at $gpg_backup"
}

### Menu
usage() {
    echo
    echo "Usage:"
    echo "  veracrypt"
    echo "  gnupg"
    echo
}
main() {
    local cmd=$1

    # return error if nothing is specified
    if [[ -z "$cmd" ]]; then
        usage
        exit 1
    fi

    if [[ $cmd == "cryptsetup" ]]; then
        cryptsetup_backup
    elif [[ $cmd == "gnupg" ]]; then
        gnupg_backup
    else
        usage
    fi
}

main "$@"
