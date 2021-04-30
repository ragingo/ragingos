#!/bin/bash -eux

# ボリューム名
readonly VOLUME_NAME=RAGINGOS
# .efi を書き込むイメージファイル名
readonly DISK_FILE_NAME=disk.img
# .efi
readonly EFI_FILE_NAME=BOOTX64.EFI
# マウントポイント
readonly MOUNT_POINT=./mnt

if [[ -e $MOUNT_POINT ]]; then
  rm -rf $MOUNT_POINT
  rm $DISK_FILE_NAME
fi

# イメージファイル作成
qemu-img create -f raw $DISK_FILE_NAME 200M

# イメージファイルを FAT でフォーマット
# https://man7.org/linux/man-pages/man8/mkfs.fat.8.html
mkfs.fat -n "$VOLUME_NAME" -s 2 -F 32 $DISK_FILE_NAME

# マウント先ディレクトリを作成
mkdir -p $MOUNT_POINT

# 📝 WSL1 Ubuntu 20.04 で実行すると "mount: ./mnt: mount failed: Operation not permitted." が発生した
# 📝 WSL2 に変換したら成功した
sudo mount -o loop $DISK_FILE_NAME $MOUNT_POINT

sudo mkdir -p $MOUNT_POINT/EFI/BOOT
sudo cp $EFI_FILE_NAME $MOUNT_POINT/EFI/BOOT/$EFI_FILE_NAME

sudo umount $MOUNT_POINT
rm -r $MOUNT_POINT
