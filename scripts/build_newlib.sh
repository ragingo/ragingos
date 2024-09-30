#!/bin/bash -eux

NEWLIB_VERSION=4.4.0
NEWLIB_TAG=newlib-$NEWLIB_VERSION

CC=clang
CXX=clang++
TARGET_TRIPLE=x86_64-elf
CFLAGS="-nostdlibinc -O2 -D__ELF__ -D_LDBL_EQ_DBL -U_GNU_SOURCE -D_POSIX_TIMERS -fPIC -U__XSI_VISIBLE"

pushd ./lib
rm -rf ./newlib
rm -rf ./newlib_build
git clone --depth=1 -b $NEWLIB_TAG https://github.com/mirror/newlib-cygwin.git newlib

mkdir newlib_build
pushd newlib_build

../newlib/newlib/configure \
  CC=$CC \
  CFLAGS="$CFLAGS" \
  --host=$TARGET_TRIPLE \
  --target=$TARGET_TRIPLE \
  --prefix=$(pwd) \
  --disable-multilib \
  --disable-newlib-multithread

make -j$(nproc)
make install

popd
popd
