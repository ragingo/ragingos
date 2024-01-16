#　hankaku.o がディレクトリパスの影響を受ける・・・（シンボル名にディレクトリパスが入る）
TARGET_DIR = ../../build/kernel
TARGET = ../../build/kernel/kernel.elf
SRCDIR = .

OBJS = \
	$(TARGET_DIR)/main.o \
	$(TARGET_DIR)/graphics.o \
	$(TARGET_DIR)/mouse.o \
	$(TARGET_DIR)/font.o \
	$(TARGET_DIR)/hankaku.o \
	$(TARGET_DIR)/newlib_support.o \
	$(TARGET_DIR)/console.o \
	$(TARGET_DIR)/pci.o \
	$(TARGET_DIR)/asmfunc.o \
	$(TARGET_DIR)/libcxx_support.o \
	$(TARGET_DIR)/logger.o \
	$(TARGET_DIR)/interrupt.o \
	$(TARGET_DIR)/usb/memory.o \
	$(TARGET_DIR)/usb/device.o \
	$(TARGET_DIR)/usb/xhci/ring.o \
	$(TARGET_DIR)/usb/xhci/trb.o \
	$(TARGET_DIR)/usb/xhci/xhci.o \
	$(TARGET_DIR)/usb/xhci/port.o \
	$(TARGET_DIR)/usb/xhci/device.o \
	$(TARGET_DIR)/usb/xhci/devmgr.o \
	$(TARGET_DIR)/usb/xhci/registers.o \
	$(TARGET_DIR)/usb/classdriver/base.o \
	$(TARGET_DIR)/usb/classdriver/hid.o \
	$(TARGET_DIR)/usb/classdriver/keyboard.o \
	$(TARGET_DIR)/usb/classdriver/mouse.o
DEPENDS = $(join $(dir $(OBJS)),$(addprefix .,$(notdir $(OBJS:.o=.d))))

CPPFLAGS += -I.
CFLAGS   += -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone
CXXFLAGS += -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone \
            -fno-exceptions -fno-rtti -std=c++17
LDFLAGS  += --entry KernelMain -z norelro --image-base 0x100000 --static

.PHONY: all
all: setup $(TARGET)

setup:
	mkdir -p $(TARGET_DIR)/usb/xhci
	mkdir -p $(TARGET_DIR)/usb/classdriver

$(TARGET): $(OBJS) Makefile
	ld.lld $(LDFLAGS) -o $@ $(OBJS) -lc -lc++

$(TARGET_DIR)/%.o: $(SRCDIR)/%.cpp Makefile
	clang++ $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(TARGET_DIR)/.%.d: $(SRCDIR)/%.cpp
	clang++ $(CPPFLAGS) $(CXXFLAGS) -MM $< > $@
	$(eval OBJ = $(TARGET_DIR)/$(patsubst $(SRCDIR)/%.cpp,%.o,$<))
	sed --in-place 's|$(notdir $(OBJ))|$(OBJ)|' $@

$(TARGET_DIR)/%.o: $(SRCDIR)/%.c Makefile
	clang $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(TARGET_DIR)/.%.d: $(SRCDIR)/%.c
	clang $(CPPFLAGS) $(CFLAGS) -MM $< > $@
	$(eval OBJ = $(TARGET_DIR)/$(patsubst $(SRCDIR)/%.c,%.o,$<))
	sed --in-place 's|$(notdir $(OBJ))|$(OBJ)|' $@

$(TARGET_DIR)/%.o: $(SRCDIR)/%.asm Makefile
	nasm -f elf64 -o $@ $<

HANKAKU_BIN = $(TARGET_DIR)/hankaku.bin
HANKAKU_O = $(TARGET_DIR)/hankaku.o

$(HANKAKU_BIN): $(SRCDIR)/hankaku.txt
	../../tools/makefont.py -o $(HANKAKU_BIN) $(SRCDIR)/hankaku.txt

$(HANKAKU_O): $(HANKAKU_BIN)
	# --redefine-sym _binary_______build_kernel_hankaku_bin_start=_binary_hankaku_bin_start をやっても書き換わらない
	objcopy -I binary -O elf64-x86-64 -B i386:x86-64 $(HANKAKU_BIN) $(HANKAKU_O)

$(TARGET_DIR)/.%.d: $(TARGET_DIR)/%.bin
	touch $@

.PHONY: depends
depends:
	$(MAKE) $(DEPENDS)

-include $(DEPENDS)
