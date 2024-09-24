#!/bin/bash -eux

# 出力先ディレクトリ
readonly BUILD_PATH=./build
# リソースディレクトリ
readonly RESOURCE_PATH=./res
# ボリューム名
readonly VOLUME_NAME=RAGINGOS
# .efi を書き込むイメージファイル名
readonly DISK_FILE_PATH=$BUILD_PATH/disk.img
# .efi
readonly EFI_FILE_PATH=$1
# kernel.elf
readonly KERNEL_FILE_PATH=$BUILD_PATH/kernel/kernel.elf
# マウントポイント
readonly MOUNT_POINT=./build/mnt

if [[ -e $MOUNT_POINT ]]; then
  rm -rf $MOUNT_POINT
  rm $DISK_FILE_PATH
fi

# イメージファイル作成
qemu-img create -f raw $DISK_FILE_PATH 200M

# イメージファイルを FAT でフォーマット
# https://man7.org/linux/man-pages/man8/mkfs.fat.8.html
mkfs.fat -n "$VOLUME_NAME" -s 2 -f 2 -R 32 -F 32 $DISK_FILE_PATH

# マウント先ディレクトリを作成
mkdir -p $MOUNT_POINT

# 📝 WSL1 Ubuntu 20.04 で実行すると "mount: ./mnt: mount failed: Operation not permitted." が発生した
# 📝 WSL2 に変換したら成功した
sudo mount -o loop $DISK_FILE_PATH $MOUNT_POINT

sudo mkdir -p $MOUNT_POINT/EFI/BOOT
sudo cp "$EFI_FILE_PATH" "$MOUNT_POINT/EFI/BOOT/BOOTX64.EFI"
sudo cp "$KERNEL_FILE_PATH" "$MOUNT_POINT/$(basename $KERNEL_FILE_PATH)"

sudo mkdir -p $MOUNT_POINT/apps
sudo rsync -rltD --exclude='*.o' $BUILD_PATH/apps/ $MOUNT_POINT/apps

sudo mkdir -p $MOUNT_POINT/res
sudo rsync -rltD $RESOURCE_PATH/ $MOUNT_POINT/res

sudo ls -lr $MOUNT_POINT

sudo umount $MOUNT_POINT
rm -r $MOUNT_POINT
