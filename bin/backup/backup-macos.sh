#!/bin/bash

# check if running compatible OS
[[ $OSTYPE = darwin* ]] || { echo >&2 "You are not running macOS or Linux. Exiting."; exit 1; }

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

### Veracrypt
veracrypt_backup() {
    veracrypt_path=/Applications/VeraCrypt.app/Contents/MacOS/VeraCrypt
    container_path="$HOME"/Desktop/backup.hc
    volume_path=/Volumes/backup

    compress_backup

    # Calculating the size of the container.
    zip_size_raw=`du -m "$tarfile" | cut -f1`
    zip_size=$(( $zip_size_raw + 5 ))

    echo "Creating container..."
    $veracrypt_path --text \
                    --create \
                    --encryption=aes-twofish-serpent \
                    --hash=whirlpool \
                    --random-source=/dev/urandom \
                    --size="${zip_size}"M \
                    --volume-type=normal \
                    --filesystem=FAT \
                    --pim=0 \
                    --protect-hidden=no \
                    --keyfiles="" \
                    --no-size-check \
                    "$container_path"

    echo "Mounting container..."
    $veracrypt_path --text \
                    --hash=whirlpool \
                    --protect-hidden=no \
                    --keyfiles="" \
                    --pim=0 \
                    "$container_path" \
                    $volume_path

    echo "Copying backup zipfile..."
    cp -r "$tarfile" $volume_path

    echo "Unmounting all VeraCrypt volumes..."
    $veracrypt_path -d

    sync

    echo "Backup container saved at $container_path"
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

    if [[ $cmd == "veracrypt" ]]; then
        veracrypt_backup
    elif [[ $cmd == "gnupg" ]]; then
        gnupg_backup
    else
        usage
    fi
}

main "$@"
