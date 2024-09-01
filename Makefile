SHELL=/bin/bash

.PHONY: all
all: build_edk2 build_kernel make_os_disk run_os_disk

.PHONY: clean
clean: clean_kernel
	-rm ./build/*

.PHONY: clean_kernel
clean_kernel:
	-rm -rf ./build/kernel

.PHONY: build_edk2
build_edk2:
	./scripts/build_edk2.sh

.PHONY: make_os_disk
make_os_disk:
	./scripts/make_os_disk.sh ~/edk2/Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi

.PHONY: run_os_disk
run_os_disk:
	./scripts/run_os_disk.sh

.PHONY: build_kernel
build_kernel:
	./scripts/build_kernel.sh

.PHONY: format_code
format_code:
	./scripts/formatter.sh
