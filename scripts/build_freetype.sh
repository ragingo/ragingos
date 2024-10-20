#!/bin/bash -eux

FREETYPE_TAG=VER-2-13-3

CC=clang
TARGET_TRIPLE=x86_64-elf
CFLAGS="-nostdlibinc -O2 -D__ELF__ -D_LDBL_EQ_DBL -U_GNU_SOURCE -D_POSIX_TIMERS -fPIC -U__XSI_VISIBLE"
NEWLIB_INCLUDES="$(realpath ./lib/newlib_build/$TARGET_TRIPLE/include)"

pushd ./lib
rm -rf ./freetype
rm -rf ./freetype_build
git clone --depth=1 -b $FREETYPE_TAG https://github.com/freetype/freetype.git

pushd freetype
./autogen.sh
popd

mkdir freetype_build
pushd freetype_build

../freetype/configure \
  CC=$CC \
  CFLAGS="-I$NEWLIB_INCLUDES $CFLAGS" \
  --host=$TARGET_TRIPLE \
  --prefix=$(pwd)

make -j$(nproc)
make install

popd
popd
