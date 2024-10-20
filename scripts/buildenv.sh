#!/bin/bash -eux

export EDK2_HOME=$(realpath -m ./lib/edk2)
export EFI_FILE_PATH=$EDK2_HOME/Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi

if [ ! -d $EDK2_HOME ]; then
  echo "$EDK2_HOME が存在しません。"
  echo "tianocore/edk2 をダウンロードします。"

  mkdir -p $EDK2_HOME
  git clone --depth=1 https://github.com/tianocore/edk2.git $EDK2_HOME
  pushd $EDK2_HOME
  git fetch --depth=1 --tags
  git checkout tags/edk2-stable202408
  # BaseTools/Source/C のビルドを通すため、 BaseTools/Source/C/BrotliCompress/brotli を取得
  git submodule update --init --depth=1 BaseTools/Source/C/BrotliCompress/brotli
  # RagingosLoaderPkg のビルドを通すため、 MdePkg/Library/MipiSysTLib/mipisyst を取得
  git submodule update --init --depth=1 MdePkg/Library/MipiSysTLib/mipisyst
  make -C BaseTools/Source/C
  popd
fi

export CC=clang
export CXX=clang++
export LD=ld.lld
export AS=nasm

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
