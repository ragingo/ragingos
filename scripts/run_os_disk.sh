#!/bin/bash -eux

# 出力先ディレクトリ
readonly OUTPUT_PATH=./build

pushd $OUTPUT_PATH > /dev/null

cp ../lib/edk2/Build/OvmfX64/DEBUG_GCC5/FV/OVMF.fd OVMF_SELF_BUILD.fd
cp /usr/share/ovmf/OVMF.fd OVMF_Ubuntu24-apt.fd

popd > /dev/null

# FIRMWARE=""
# FIRMWARE="-bios $OUTPUT_PATH/DEBUGX64_OVMF.fd"
# FIRMWARE="-bios $OUTPUT_PATH/OVMF_Ubuntu22-apt.fd"
# FIRMWARE="-bios $OUTPUT_PATH/OVMF_Ubuntu24-apt.fd"
# FIRMWARE="-bios $OUTPUT_PATH/OVMF_SELF_BUILD.fd"
# FIRMWARE="\
#   -drive if=pflash,format=raw,readonly=on,file=$OUTPUT_PATH/OSBOOK_OVMF_CODE.fd \
#   -drive if=pflash,format=raw,file=$OUTPUT_PATH/OSBOOK_OVMF_VARS.fd
# "

QEMU_OPTS=""
# QEMU_OPTS="-gdb tcp::12345 -S"
QEMU_OPTS="-debugcon file:debug.log -global isa-debugcon.iobase=0x402 -d int -D qemu.log"

qemu-system-x86_64 \
  $FIRMWARE \
  -device qemu-xhci \
  -m 2G \
  -drive if=ide,index=0,media=disk,format=raw,file=$OUTPUT_PATH/disk.img \
  -device usb-kbd \
  -device usb-tablet,usb_version=1 \
  -monitor stdio \
  --no-reboot \
  --no-shutdown \
  $QEMU_OPTS
