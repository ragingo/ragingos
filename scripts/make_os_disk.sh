#!/bin/bash -eux

source ./scripts/buildenv.sh

# 出力先ディレクトリ
readonly BUILD_PATH=./build
# リソースディレクトリ
readonly RESOURCE_PATH=./res
# ボリューム名
readonly VOLUME_NAME=RAGINGOS
# .efi を書き込むイメージファイル名
readonly DISK_FILE_PATH=$BUILD_PATH/disk.img
# kernel.elf
readonly KERNEL_FILE_PATH=$BUILD_PATH/kernel/kernel.elf
# マウントポイント
readonly MOUNT_POINT=./build/mnt

# sudo が必要か判定（WSL2では必要、Docker rootでは不要）
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi
if [ -n "$SUDO" ] && ! command -v sudo >/dev/null 2>&1; then
  echo "sudo not found" >&2
  exit 1
fi

if [[ -e $MOUNT_POINT ]]; then
  $SUDO umount -l $MOUNT_POINT 2>/dev/null || true
  rm -rf $MOUNT_POINT
  rm $DISK_FILE_PATH || true
fi

# イメージファイル作成
qemu-img create -f raw $DISK_FILE_PATH 200M

# イメージファイルを FAT でフォーマット
# https://man7.org/linux/man-pages/man8/mkfs.fat.8.html
mkfs.fat -n "$VOLUME_NAME" -s 2 -f 2 -R 32 -F 32 $DISK_FILE_PATH

# マウント先ディレクトリを作成
mkdir -p $MOUNT_POINT

# loop mount が可能なら従来通り、不可なら mtools で代替（Docker等でSYS_ADMIN無しでも動作）
if $SUDO mount -o loop $DISK_FILE_PATH $MOUNT_POINT 2>/dev/null; then
  $SUDO mkdir -p $MOUNT_POINT/EFI/BOOT
  $SUDO cp "$EFI_FILE_PATH" "$MOUNT_POINT/EFI/BOOT/BOOTX64.EFI"
  $SUDO cp "$KERNEL_FILE_PATH" "$MOUNT_POINT/$(basename $KERNEL_FILE_PATH)"

  $SUDO mkdir -p $MOUNT_POINT/apps
  $SUDO rsync -rltD --exclude='*.o' $BUILD_PATH/apps/ $MOUNT_POINT/apps

  $SUDO mkdir -p $MOUNT_POINT/res
  $SUDO rsync -rltD $RESOURCE_PATH/ $MOUNT_POINT/res

  $SUDO ls -lr $MOUNT_POINT

  $SUDO umount -l $MOUNT_POINT
  rm -r $MOUNT_POINT
else
  echo "loop mount failed, falling back to mtools" >&2
  # mtools は -i で直接イメージを操作するため mount 不要
  mmd -i $DISK_FILE_PATH ::/EFI ::/EFI/BOOT ::/apps ::/res
  mcopy -i $DISK_FILE_PATH "$EFI_FILE_PATH" ::/EFI/BOOT/BOOTX64.EFI
  mcopy -i $DISK_FILE_PATH "$KERNEL_FILE_PATH" ::/
  # apps/*.o を除外してコピー
  for f in $BUILD_PATH/apps/*; do
    case "$f" in *.o) continue;; esac
    [ -e "$f" ] || continue
    mcopy -i $DISK_FILE_PATH "$f" ::/apps/
  done
  for f in $RESOURCE_PATH/*; do
    [ -e "$f" ] || continue
    mcopy -i $DISK_FILE_PATH "$f" ::/res/
  done
  mdir -i $DISK_FILE_PATH ::/
  rm -r $MOUNT_POINT 2>/dev/null || true
fi
