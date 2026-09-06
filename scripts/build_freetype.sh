#!/bin/bash -eux

FREETYPE_TAG=VER-2-13-3

TARGET_TRIPLE=x86_64-elf
LD=mold
NEWLIB_INCLUDES="$(realpath ./lib/newlib_build/$TARGET_TRIPLE/include)"
CFLAGS="-I$NEWLIB_INCLUDES -nostdlibinc -O2 -D__ELF__ -D_LDBL_EQ_DBL -U_GNU_SOURCE -D_POSIX_TIMERS -fPIC -U__XSI_VISIBLE --target=$TARGET_TRIPLE -Wno-keyword-macro -Wno-gnu-include-next"
CC=clang

# aarch64 Linux (Docker on macOS) では clang --target=x86_64-elf が
# host gcc (aarch64) に -m64 を渡してリンクが失敗するため、configure の
# リンクテストをラップする。
if [ "$(uname -m)" = "aarch64" ] && [ "$(uname -s)" = "Linux" ]; then
  CC="$(realpath ./scripts/clang_wrapper_elf.sh)"
fi

pushd ./lib
rm -rf ./freetype_build
if [ ! -d ./freetype ]; then
  git clone --depth=1 -b $FREETYPE_TAG https://github.com/freetype/freetype.git
fi

pushd freetype
./autogen.sh
popd

mkdir freetype_build
pushd freetype_build

../freetype/configure \
  CC="$CC" \
  LD="$LD" \
  CFLAGS="$CFLAGS" \
  --host=$TARGET_TRIPLE \
  --disable-mmap \
  --prefix=$(pwd)

make -j
make install

popd
popd
