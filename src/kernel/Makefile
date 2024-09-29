#　hankaku.o がディレクトリパスの影響を受ける・・・（シンボル名にディレクトリパスが入る）
TARGET_DIR = ../../build/kernel
TARGET = ../../build/kernel/kernel.elf
SRC_DIR = .
SRC_FILES := $(shell find $(SRC_DIR) -name '*.c' -or -name '*.cpp' -or -name '*.asm')

OBJS := $(patsubst $(SRC_DIR)/%.c,  $(TARGET_DIR)/%.o,$(filter %.c,  $(SRC_FILES))) \
        $(patsubst $(SRC_DIR)/%.cpp,$(TARGET_DIR)/%.o,$(filter %.cpp,$(SRC_FILES))) \
        $(patsubst $(SRC_DIR)/%.asm,$(TARGET_DIR)/%.o,$(filter %.asm,$(SRC_FILES)))
OBJS += $(TARGET_DIR)/hankaku.o

DEPENDS = $(OBJS:.o=.d)

CPPFLAGS += -I.
CFLAGS   += -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone -fshort-wchar
CXXFLAGS += -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone -fshort-wchar \
            -fno-exceptions -fno-rtti -std=c++23
LDFLAGS  += --entry KernelMain -z norelro --image-base 0x100000 --static

.PHONY: all
all: setup $(TARGET)

setup:
	mkdir -p $(TARGET_DIR)/drivers
	mkdir -p $(TARGET_DIR)/drivers/usb/classdriver
	mkdir -p $(TARGET_DIR)/drivers/usb/xhci
	mkdir -p $(TARGET_DIR)/ui

$(TARGET): $(OBJS) Makefile
	$(LD) $(LDFLAGS) -o $@ $(OBJS) -lc -lc++ -lc++abi -lm  -lfreetype

$(TARGET_DIR)/%.o: $(SRC_DIR)/%.cpp Makefile
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(TARGET_DIR)/.%.d: $(SRC_DIR)/%.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MM $< > $@
	$(eval OBJ = $(TARGET_DIR)/$(patsubst $(SRC_DIR)/%.cpp,%.o,$<))
	sed --in-place 's|$(notdir $(OBJ))|$(OBJ)|' $@

$(TARGET_DIR)/%.o: $(SRC_DIR)/%.c Makefile
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(TARGET_DIR)/.%.d: $(SRC_DIR)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -MM $< > $@
	$(eval OBJ = $(TARGET_DIR)/$(patsubst $(SRC_DIR)/%.c,%.o,$<))
	sed --in-place 's|$(notdir $(OBJ))|$(OBJ)|' $@

$(TARGET_DIR)/%.o: $(SRC_DIR)/%.asm Makefile
	$(AS) -f elf64 -o $@ $<

HANKAKU_BIN = $(TARGET_DIR)/hankaku.bin
HANKAKU_O = $(TARGET_DIR)/hankaku.o

$(HANKAKU_BIN): $(SRC_DIR)/hankaku.txt
	../../tools/makefont.py -o $(HANKAKU_BIN) $(SRC_DIR)/hankaku.txt

$(HANKAKU_O): $(HANKAKU_BIN)
	# --redefine-sym _binary_______build_kernel_hankaku_bin_start=_binary_hankaku_bin_start をやっても書き換わらない
	objcopy -I binary -O elf64-x86-64 -B i386:x86-64 $(HANKAKU_BIN) $(HANKAKU_O)

$(TARGET_DIR)/.%.d: $(TARGET_DIR)/%.bin
	touch $@

.PHONY: depends
depends:
	$(MAKE) $(DEPENDS)

-include $(DEPENDS)
