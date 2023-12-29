#!/bin/bash -eux

# shellcheck disable=SC1090
source ~/osbook/devenv/buildenv.sh

mkdir -p ./build/kernel
# shellcheck disable=SC2086
clang++ $CPPFLAGS -O0 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone -fno-exceptions -fno-rtti -std=c++17 -c ./src/kernel/main.cpp -o ./build/kernel/main.o
# shellcheck disable=SC2086
ld.lld $LDFLAGS --entry KernelMain -z norelro --image-base 0x100000 --static -o ./build/kernel/kernel.elf ./build/kernel/main.o
