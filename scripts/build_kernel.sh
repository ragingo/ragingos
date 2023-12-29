#!/bin/bash -eux

# shellcheck disable=SC1090
source ~/osbook/devenv/buildenv.sh

mkdir -p ./build/kernel

pushd ./src/kernel
make
popd
