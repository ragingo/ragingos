#!/bin/bash -ex

EDK2_HOME=$(realpath -m ./lib/edk2)

if [ ! -d $EDK2_HOME ]; then
  mkdir -p $EDK2_HOME
  git clone --depth=1 https://github.com/tianocore/edk2.git $EDK2_HOME
  pushd $EDK2_HOME
  git fetch --depth=1 --tags
  git checkout tags/edk2-stable202411
  # BaseTools/Source/C ビルド用
  git submodule update --init --depth=1 BaseTools/Source/C/BrotliCompress/brotli
  # RagingosLoaderPkg ビルド用
  git submodule update --init --depth=1 MdePkg/Library/MipiSysTLib/mipisyst
  # OvmfPkg ビルド用
  git submodule update --init --depth=1 MdeModulePkg/Library/BrotliCustomDecompressLib/brotli
  git submodule update --init --depth=1 CryptoPkg/Library/OpensslLib/openssl
  git submodule update --init --depth=1 CryptoPkg/Library/MbedTlsLib/mbedtls
  git submodule update --init --depth=1 SecurityPkg/DeviceSecurity/SpdmLib/libspdm
  make -C BaseTools/Source/C
  popd
fi

cp -p ./setup/edk2/tools_def.txt $EDK2_HOME/Conf/tools_def.txt

# OvmfPkg のビルド
cp -p ./setup/edk2/target_OvmfPkg.txt $EDK2_HOME/Conf/target.txt

pushd $EDK2_HOME
source ./edksetup.sh
build
popd

# RagingosLoaderPkg のビルド
ln -fs $(realpath ./src/RagingosLoaderPkg) $EDK2_HOME/
cp -p ./setup/edk2/target_RagingosLoaderPkg.txt $EDK2_HOME/Conf/target.txt

pushd $EDK2_HOME
source ./edksetup.sh
build
popd
