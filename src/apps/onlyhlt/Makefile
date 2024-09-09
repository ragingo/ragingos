TARGET = ../../../build/apps/onlyhlt
TARGET_DIR = ../../../build/apps

.PHONY: all
all: setup $(TARGET)

.PHONY: setup
setup:
	mkdir -p $(TARGET_DIR)

$(TARGET): Makefile

$(TARGET_DIR)/onlyhlt: onlyhlt.asm Makefile
	nasm -f bin -o $@ $<
