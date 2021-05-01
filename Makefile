SHELL=/bin/bash

all: build make_disk run

.PHONY: build
build:
	./scripts/build.sh

make_disk:
	./scripts/make_disk.sh ~/edk2/Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi

.PHONY: run
run:
	./scripts/run_disk.sh
