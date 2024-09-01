SHELL=/bin/bash

.PHONY: all
all: build_edk2 build_kernel make_os_disk run_os_disk

.PHONY: clean
clean: clean_kernel
	-rm ./build/*

clean_kernel:
	-rm -rf ./build/kernel

build_edk2:
	./scripts/build_edk2.sh

make_os_disk:
	./scripts/make_os_disk.sh ~/edk2/Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi

run_os_disk:
	./scripts/run_os_disk.sh

build_kernel:
	./scripts/build_kernel.sh

format_code:
	./scripts/formatter.sh
