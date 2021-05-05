SHELL=/bin/bash

all: build_edk2 build_kernel make_disk run_disk

build_edk2:
	./scripts/build_edk2.sh

make_disk:
	./scripts/make_disk.sh ~/edk2/Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi

run_disk:
	./scripts/run_disk.sh

build_kernel:
	mkdir -p ./build/kernel
	clang++ -O0 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone -fno-exceptions -fno-rtti -std=c++17 -c ./src/kernel/main.cpp -o ./build/kernel/main.o
	ld.lld --entry KernelMain -z norelro --image-base 0x100000 --static -o ./build/kernel/kernel.elf ./build/kernel/main.o
