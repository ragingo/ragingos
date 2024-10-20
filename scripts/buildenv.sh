#!/bin/bash -eux

export CC=clang
export CXX=clang++
export LD=ld.lld
export AS=nasm

export EDK2_HOME=$(realpath -m ./lib/edk2)
export EFI_FILE_PATH=$EDK2_HOME/Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi
export NEWLIB_DIR=$(realpath -m ./lib/newlib_build/x86_64-elf)
export CXX_ABI_DIR=$(realpath -m ./lib/llvm_libcxxabi_build)
export CXX_DIR=$(realpath -m ./lib/llvm_libcxx_build)
export FREETYPE_DIR=$(realpath -m ./lib/freetype_build)

export CPPFLAGS="\
  -I$CXX_ABI_DIR/include/c++/v1 \
  -I$CXX_DIR/include/c++/v1 \
  -I$NEWLIB_DIR/include \
  -I$FREETYPE_DIR/include/freetype2 \
  -I$EDK2_HOME/MdePkg/Include \
  -I$EDK2_HOME/MdePkg/Include/X64 \
  -nostdlibinc \
  -D__ELF__ \
  -D_GNU_SOURCE \
  -D_LDBL_EQ_DBL \
  -D_POSIX_TIMERS \
  -DEFIAPI='__attribute__((ms_abi))'\
"

export LDFLAGS="\
  -L$CXX_ABI_DIR/lib \
  -L$CXX_DIR/lib \
  -L$NEWLIB_DIR/lib \
  -L$FREETYPE_DIR/lib\
"
