#!/bin/bash

tmpdir=$(mktemp -d)
tarfile="$tmpdir"/backup.tar.gz
gpgfile="$HOUSE"/backup.tar.gz.gpg
gpgbfold="$HOME"/gnupg-backup-files
sshbfold="$HOME"/ssh-backup-files

echo "Copying and exporting GPG files..."
mkdir "$HOME"/gnupg-backup-files
cp -r "$HOME"/.gnupg/private-keys-v1.d "$gpgbfold"/
cp "$HOME"/.gnupg/pubring.kbx "$gpgbfold"
gpg --export-ownertrust > "$gpgbfold"/ownertrust.txt

echo "Copying SSH files..."
mkdir "$HOME"/ssh-backup-files
cp "$HOME"/.ssh/config "$sshbfold"
cp "$HOME"/.ssh/id_rsa "$sshbfold"
cp "$HOME"/.ssh/id_rsa-putty.ppk "$sshbfold"
cp "$HOME"/.ssh/id_rsa.pub "$sshbfold"

echo "Creating tar file..."
tar -zcf "$tarfile" \
  --exclude="Music" \
  --exclude=".seafile-data" \
  --exclude="vz" \
  --exclude="Desktop.ini" \
  --exclude=".git" \
  --exclude=".DS_Store" \
  -C "$CLOUD_DIR" . \
  -C "$HOME" dotfiles ssh-backup-files gnupg-backup-files

sleep 5

echo "Encrypting tar file..."
gpg --symmetric \
  --s2k-mode 3 \
  --s2k-cipher-algo AES256 \
  --s2k-digest-algo SHA512 \
  --s2k-count 65000000 \
  -o "$gpgfile" \
  "$tarfile"

sleep 5

echo "Deleting temp folder..."
rm -rf "$tmpdir"

echo "Deleting SSH and GPG backup folders..."
rm -rf "$gpgbfold"
rm -rf "$sshbfold"

echo "Backup file saved at $gpgfile"
