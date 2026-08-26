#!/bin/bash -eux

export CC=clang
export CXX=clang++
export LD=ld.lld
export AS=nasm

export EDK2_HOME=$(realpath -m ./lib/edk2)
export EFI_FILE_PATH=$EDK2_HOME/Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi
export NEWLIB_DIR=$(realpath -m ./lib/newlib_build/x86_64-elf)
export CXX_RUNTIMES_DIR="$(realpath -m ./lib/llvm_runtimes_build)"
export FREETYPE_DIR=$(realpath -m ./lib/freetype_build)

export CPPFLAGS="\
  -I${CXX_RUNTIMES_DIR}/include/c++/v1 \
  -I$NEWLIB_DIR/include \
  -I$FREETYPE_DIR/include/freetype2 \
  -I$EDK2_HOME/MdePkg/Include \
  -I$EDK2_HOME/MdePkg/Include/X64 \
  -nostdlibinc \
  -D__ELF__ \
  -D_GNU_SOURCE \
  -D_LDBL_EQ_DBL \
  -D_POSIX_TIMERS \
  -D_LIBCPP_PROVIDES_DEFAULT_RUNE_TABLE \
  -DEFIAPI='__attribute__((ms_abi))'\
 "

export LDFLAGS="\
  -L${CXX_RUNTIMES_DIR}/lib \
  -L$NEWLIB_DIR/lib \
  -L$FREETYPE_DIR/lib\
"
