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
  -drive if=pflash,file=$OUTPUT_PATH/OVMF_CODE.fd \
  -drive if=pflash,file=$OUTPUT_PATH/OVMF_VARS.fd \
  -hda $OUTPUT_PATH/disk.img \
  -monitor stdio
