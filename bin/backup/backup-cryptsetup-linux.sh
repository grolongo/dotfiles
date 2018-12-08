#!/bin/bash

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
