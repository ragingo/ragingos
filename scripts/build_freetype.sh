#!/bin/bash -eux

FREETYPE_TAG=VER-2-13-3

TARGET_TRIPLE=x86_64-elf
NEWLIB_INCLUDES="$(realpath ./lib/newlib_build/$TARGET_TRIPLE/include)"
# aarch64 Linux (Docker on macOS) では clang --target=x86_64-elf が
# host gcc (aarch64) に -m64 を渡してリンクが失敗するため、configure の
# リンクテストをラップする。
if [ "$(uname -m)" = "aarch64" ] && [ "$(uname -s)" = "Linux" ]; then
  WRAPPER="/tmp/clang_wrapper_elf.sh"
  cat > "$WRAPPER" << 'WRAPPER_EOF'
#!/bin/bash
has_c=false
has_conftest=false
for arg in "$@"; do
  if [ "$arg" = "-c" ]; then has_c=true; fi
  if [[ "$arg" == *conftest* ]]; then has_conftest=true; fi
done
if [ "$has_conftest" = true ] && [ "$has_c" = false ]; then
  for arg in "$@"; do
    if [ "$prev" = "-o" ]; then touch "$arg"; chmod +x "$arg" 2>/dev/null || true; exit 0; fi
    prev="$arg"
  done
  touch conftest; chmod +x conftest 2>/dev/null || true; exit 0
fi
exec clang "$@"
WRAPPER_EOF
  chmod +x "$WRAPPER"
  CC="$WRAPPER"
  FREETYPE_HOST_TRIPLE=$TARGET_TRIPLE
  CFLAGS="-nostdlibinc -O2 -D__ELF__ -D_LDBL_EQ_DBL -U_GNU_SOURCE -D_POSIX_TIMERS -fPIC -U__XSI_VISIBLE --target=$TARGET_TRIPLE"
else
  CC=clang
  FREETYPE_HOST_TRIPLE=$TARGET_TRIPLE
  CFLAGS="-nostdlibinc -O2 -D__ELF__ -D_LDBL_EQ_DBL -U_GNU_SOURCE -D_POSIX_TIMERS -fPIC -U__XSI_VISIBLE --target=$TARGET_TRIPLE"
fi

pushd ./lib
# newlib には sys/mman.h が無いため、freetype の builds/unix/ftsystem.c が
# 必要とするヘッダをスタブで補う（bare-metal では mmap は未使用）
if [ ! -f ./newlib_build/$TARGET_TRIPLE/include/sys/mman.h ]; then
  mkdir -p ./newlib_build/$TARGET_TRIPLE/include/sys
  cat > ./newlib_build/$TARGET_TRIPLE/include/sys/mman.h << 'MMAN_EOF'
#pragma once
#include <sys/types.h>
#define PROT_READ  0x1
#define PROT_WRITE 0x2
#define MAP_FAILED ((void*)-1)
#define MAP_FILE 0x00
#define MAP_SHARED 0x01
#define MAP_PRIVATE 0x02
#define MAP_FIXED 0x10
static inline void* mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset) { return MAP_FAILED; }
static inline int munmap(void *addr, size_t len) { return -1; }
MMAN_EOF
fi

rm -rf ./freetype
rm -rf ./freetype_build
git clone --depth=1 -b $FREETYPE_TAG https://github.com/freetype/freetype.git

pushd freetype
./autogen.sh
popd

mkdir freetype_build
pushd freetype_build

../freetype/configure \
  CC="$CC" \
  CFLAGS="-I$NEWLIB_INCLUDES $CFLAGS" \
  --host=$FREETYPE_HOST_TRIPLE \
  --prefix=$(pwd)

make -j
make install

popd
popd
