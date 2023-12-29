#!/bin/bash -eux

# 出力先ディレクトリ
readonly OUTPUT_PATH=./build

pushd $OUTPUT_PATH > /dev/null

if [[ ! -e ./OVMF_CODE.fd ]]; then
  curl -OL https://github.com/uchan-nos/mikanos-build/raw/master/devenv/OVMF_CODE.fd
fi
if [[ ! -e ./OVMF_VARS.fd ]]; then
  curl -OL https://github.com/uchan-nos/mikanos-build/raw/master/devenv/OVMF_VARS.fd
fi

popd > /dev/null

qemu-system-x86_64 \
  -m 1G \
  -drive if=pflash,format=raw,readonly=on,file=$OUTPUT_PATH/OVMF_CODE.fd \
  -drive if=pflash,format=raw,file=$OUTPUT_PATH/OVMF_VARS.fd \
  -drive if=ide,index=0,media=disk,format=raw,file=$OUTPUT_PATH/disk.img \
  -monitor stdio
