#!/bin/bash -eux

# 出力先ディレクトリ
readonly OUTPUT_PATH=./build

pushd $OUTPUT_PATH > /dev/null

cp ../lib/edk2/Build/OvmfX64/DEBUG_CLANG38/FV/OVMF.fd OVMF_SELF_BUILD.fd
cp /usr/share/ovmf/OVMF.fd OVMF_Ubuntu26-apt.fd

popd > /dev/null

# FIRMWARE=""
# FIRMWARE="-bios $OUTPUT_PATH/OVMF_Ubuntu26-apt.fd"
FIRMWARE="-bios $OUTPUT_PATH/OVMF_SELF_BUILD.fd"

QEMU_OPTS=""
# QEMU_OPTS="-gdb tcp::12345 -S"
QEMU_OPTS="-debugcon file:debug.log -global isa-debugcon.iobase=0x402 -d int -D qemu.log"

qemu-system-x86_64 \
  $FIRMWARE \
  -m 2G \
  -drive if=ide,index=0,media=disk,format=raw,file=$OUTPUT_PATH/disk.img \
  -device nec-usb-xhci,id=xhci \
  -device usb-mouse \
  -device usb-kbd \
  -device usb-tablet \
  -display none -vnc 0.0.0.0:0 \
  -monitor stdio \
  --no-reboot \
  --no-shutdown \
  -audiodev none,id=noaudio \
  $QEMU_OPTS
