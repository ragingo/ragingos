TARGET = ../../../build/apps/rpn
TARGET_DIR = ../../../build/apps

CPPFLAGS += -I.
CFLAGS   += -O2 -Wall -g --target=x86_64-elf -ffreestanding
CXXFLAGS += -O2 -Wall -g --target=x86_64-elf -ffreestanding \
            -fno-exceptions -fno-rtti -std=c++17
LDFLAGS += --entry main -z norelro --image-base 0 --static

.PHONY: all
all: $(TARGET)

$(TARGET): $(TARGET).o Makefile
	ld.lld $(LDFLAGS) -o $(TARGET) $(TARGET).o -lc -lc++ -lc++abi

$(TARGET_DIR)/%.o: %.cpp Makefile
	clang++ $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@
