SHELL=/bin/bash

all: build_edk2 make_disk run

build_edk2:
	./scripts/build_edk2.sh

make_disk:
	./scripts/make_disk.sh ~/edk2/Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi

.PHONY: run
run:
	./scripts/run_disk.sh
