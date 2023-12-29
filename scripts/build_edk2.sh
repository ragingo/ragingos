#!/bin/bash -ex

readonly EDX2_PATH=~/edk2

pushd $EDX2_PATH

# memo: ./edksetup.sh: line 47: WORKSPACE: unbound variable
source ./edksetup.sh
build

popd
