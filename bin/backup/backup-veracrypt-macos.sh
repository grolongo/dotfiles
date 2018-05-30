#!/bin/bash

veracrypt_path=/Applications/VeraCrypt.app/Contents/MacOS/VeraCrypt
container_path=$HOME/Desktop/backup.hc
volume_path=/Volumes/backup

echo "Creating container..."
$veracrypt_path --text \
  --create \
  --encryption=aes-twofish-serpent \
  --hash=whirlpool \
  --random-source=/dev/urandom \
  --size=210M \
  --volume-type=normal \
  --filesystem=exFAT \
  --pim=0 \
  -k '' \
  "$container_path"

sleep 5

echo "Mounting container..."
$veracrypt_path --text \
  --hash=whirlpool \
  --protect-hidden=no \
  --pim=0 \
  -k '' \
  "$container_path" \
  $volume_path

sleep 5

echo "Copying notes dir..."
cp -r "$NOTES_DIR" $volume_path

echo "Copying dotfiles dir..."
rsync -av "$DOTFILES_DIR" $volume_path --exclude .git

echo "Copying documents dir..."
cp -r "$DOCUMENTS_DIR" $volume_path

echo "Copying projects dir..."
cp -r "$PROJECTS_DIR" $volume_path

echo "Copying private dir..."
cp -r "$PRIVATE_DIR" $volume_path

echo "Copying and exporting GPG files..."
mkdir "$volume_path"/gnupg-backup-files
cp -r "$HOME"/.gnupg/private-keys-v1.d "$volume_path"/gnupg-backup-files/
cp "$HOME"/.gnupg/pubring.kbx "$volume_path"/gnupg-backup-files
gpg --export-ownertrust > "$volume_path"/gnupg-backup-files/ownertrust.txt

echo "Copying SSH files..."
mkdir "$volume_path"/ssh-backup-files
cp "$HOME"/.ssh/config "$volume_path"/ssh-backup-files
cp "$HOME"/.ssh/id_rsa "$volume_path"/ssh-backup-files
cp "$HOME"/.ssh/id_rsa-putty.ppk "$volume_path"/ssh-backup-files
cp "$HOME"/.ssh/id_rsa.pub "$volume_path"/ssh-backup-files

sleep 5

echo "Unmounting and finishing..."
$veracrypt_path -d
sync

echo "Backup container saved at $container_path"
