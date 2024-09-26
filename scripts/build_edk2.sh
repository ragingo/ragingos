#!/bin/bash -ex

source ./scripts/buildenv.sh

pushd $EDK2_HOME

# memo: ./edksetup.sh: line 47: WORKSPACE: unbound variable
source ./edksetup.sh
build

popd
