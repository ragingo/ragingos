#!/bin/bash -eux

DISK_PATH=./build/fat_disk
MOUNT_POINT=./build/mnt

if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

dd if=/dev/zero of="$DISK_PATH" bs=1M count=128
mkfs.fat -n 'RAGINGOS' -s 2 -f 2 -R 32 -F 32 "$DISK_PATH"
mkdir -p "$MOUNT_POINT"
if $SUDO mount -o loop "$DISK_PATH" "$MOUNT_POINT" 2>/dev/null; then
  echo deadbeef > ./build/cafe.txt
  $SUDO cp ./build/cafe.txt ${MOUNT_POINT}/cafe.txt

  echo CafeBabe > ./build/HelloWorld.data
  $SUDO cp ./build/HelloWorld.data ${MOUNT_POINT}/HelloWorld.data

  $SUDO umount "$MOUNT_POINT"
  rm -r "$MOUNT_POINT"
else
  echo "loop mount failed, falling back to mtools" >&2
  echo deadbeef > ./build/cafe.txt
  echo CafeBabe > ./build/HelloWorld.data
  mcopy -i "$DISK_PATH" ./build/cafe.txt ::/
  mcopy -i "$DISK_PATH" ./build/HelloWorld.data ::/
  rm -r "$MOUNT_POINT" 2>/dev/null || true
fi

# ディスクの確認
# hexdump -C -s 16k ./build/fat_disk
