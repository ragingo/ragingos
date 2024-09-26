#!/bin/bash -eux

source ./scripts/buildenv.sh

mkdir -p ./build/kernel

pushd ./src/kernel
make
popd
