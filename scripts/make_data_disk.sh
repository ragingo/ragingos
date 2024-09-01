#!/bin/bash -eux

DISK_PATH=./build/fat_disk
MOUNT_POINT=./build/mnt

dd if=/dev/zero of="$DISK_PATH" bs=1M count=128
mkfs.fat -n 'RAGINGOS' -s 2 -f 2 -R 32 -F 32 "$DISK_PATH"
mkdir -p "$MOUNT_POINT"
sudo mount -o loop "$DISK_PATH" "$MOUNT_POINT"

echo deadbeef > ./build/cafe.txt
sudo cp ./build/cafe.txt ${MOUNT_POINT}/cafe.txt

echo CafeBabe > ./build/HelloWorld.data
sudo cp ./build/HelloWorld.data ${MOUNT_POINT}/HelloWorld.data

sudo umount "$MOUNT_POINT"
rm -r "$MOUNT_POINT"

# ディスクの確認
# hexdump -C -s 16k ./build/fat_disk
