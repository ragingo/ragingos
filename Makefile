SHELL=/bin/bash

.PHONY: all
all: build_edk2 build_kernel build_apps make_os_disk make_data_disk run_os_disk

.PHONY: clean
clean: clean_kernel clean_apps
	-rm ./build/*

.PHONY: clean_kernel
clean_kernel:
	-rm -rf ./build/kernel

.PHONY: clean_apps
clean_apps:
	-rm -rf ./build/apps

.PHONY: rebuild
rebuild: clean all

.PHONY: build_stdlib
build_stdlib:
	./scripts/build_newlib.sh

.PHONY: build_edk2
build_edk2:
	./scripts/build_edk2.sh

.PHONY: make_os_disk
make_os_disk:
	./scripts/make_os_disk.sh

.PHONY: run_os_disk
run_os_disk:
	./scripts/run_os_disk.sh

.PHONY: build_kernel
build_kernel:
	./scripts/build_kernel.sh

.PHONY: build_apps
build_apps:
	./scripts/build_apps.sh

.PHONY: make_data_disk
make_data_disk:
	./scripts/make_data_disk.sh

.PHONY: format_code
format_code:
	./scripts/formatter.sh
