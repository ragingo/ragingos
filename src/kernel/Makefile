TARGET_DIR = ../../build/kernel
TARGET = $(TARGET_DIR)/kernel.elf
SRCDIR = .

OBJS = $(patsubst $(SRCDIR)/%.cpp,$(TARGET_DIR)/%.o,$(wildcard $(SRCDIR)/*.cpp))
DEPENDS = $(patsubst $(SRCDIR)/%.cpp,$(TARGET_DIR)/.%.d,$(wildcard $(SRCDIR)/*.cpp))

CXXFLAGS += -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone \
            -fno-exceptions -fno-rtti -std=c++17
LDFLAGS  += --entry KernelMain -z norelro --image-base 0x100000 --static

.PHONY: all
all: $(TARGET)

$(TARGET): $(OBJS) Makefile
	ld.lld $(LDFLAGS) -o $@ $(OBJS)

$(TARGET_DIR)/%.o: $(SRCDIR)/%.cpp Makefile
	clang++ $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(TARGET_DIR)/.%.d: $(SRCDIR)/%.cpp
	clang++ $(CPPFLAGS) $(CXXFLAGS) -MM $< > $@
	$(eval OBJ = $(TARGET_DIR)/$(patsubst $(SRCDIR)/%.cpp,%.o,$<))
	sed --in-place 's|$(notdir $(OBJ))|$(OBJ)|' $@

.PHONY: depends
depends:
	$(MAKE) $(DEPENDS)

-include $(DEPENDS)
