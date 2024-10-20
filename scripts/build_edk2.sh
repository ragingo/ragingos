#!/bin/bash -ex

source ./scripts/buildenv.sh

if [ ! -d $EDK2_HOME ]; then
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

ln -fs $(realpath ./src/RagingosLoaderPkg) $EDK2_HOME/
cp -p ./setup/edk2/target.txt $EDK2_HOME/Conf/target.txt
cp -p ./setup/edk2/tools_def.txt $EDK2_HOME/Conf/tools_def.txt

pushd $EDK2_HOME

source ./edksetup.sh
build

popd
