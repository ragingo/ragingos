#!/bin/bash -ex

source ./scripts/buildenv.sh

ln -fs $(realpath ./src/RagingosLoaderPkg) $EDK2_HOME/
cp -p ./setup/edk2/target.txt $EDK2_HOME/Conf/target.txt
cp -p ./setup/edk2/tools_def.txt $EDK2_HOME/Conf/tools_def.txt

pushd $EDK2_HOME

source ./edksetup.sh
build

popd
