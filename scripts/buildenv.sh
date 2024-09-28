#!/bin/bash -eux

export EDK2_HOME=~/edk2
export STD_LIB_DIR=$(realpath ./lib/osbook/devenv/x86_64-elf)
export EFI_FILE_PATH=~/edk2/Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi

if [ ! -d $STD_LIB_DIR ]
then
  echo "$STD_LIB_DIR が存在しません。"
  echo "ファイルをダウンロードして展開します。"
  mkdir -p $(dirname $STD_LIB_DIR)
  curl -L -o /tmp/x86_64-elf.tar.gz https://github.com/uchan-nos/mikanos-build/releases/download/v2.0/x86_64-elf.tar.gz
  tar -xzf /tmp/x86_64-elf.tar.gz -C $(dirname $STD_LIB_DIR)
  echo "ダウンロードと展開が完了しました。"
fi

export CPPFLAGS="\
  -I$STD_LIB_DIR/include/c++/v1 -I$STD_LIB_DIR/include -I$STD_LIB_DIR/include/freetype2 \
  -I$EDK2_HOME/MdePkg/Include -I$EDK2_HOME/MdePkg/Include/X64 \
  -nostdlibinc -D__ELF__ -D_LDBL_EQ_DBL -D_GNU_SOURCE -D_POSIX_TIMERS \
  -DEFIAPI='__attribute__((ms_abi))'"
  export LDFLAGS="-L$STD_LIB_DIR/lib"