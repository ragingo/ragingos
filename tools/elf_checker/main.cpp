#include <elf.h>
#include <stdio.h>
#include <array>
#include <cassert>
#include <fstream>
#include <functional>
#include <string>
#include <string_view>
#include <vector>
#include "enum2str.h"

template<typename T>
T read(std::ifstream& fs) {
    T buf;
    fs.read(reinterpret_cast<char*>(&buf), sizeof(T));
    return buf;
}

template<typename T, std::size_t N>
std::array<T, N> read(std::ifstream& fs) {
    std::array<T, N> buf = { 0 };
    fs.read(reinterpret_cast<char*>(buf.data()), sizeof(T) * N);
    return buf;
}

template<typename T>
using ValueToString = std::function<std::string_view(T)>;

template<typename T>
void print(std::string_view name, T value) {
    if constexpr (std::is_same_v<T, uint8_t> || std::is_same_v<T, uint16_t> || std::is_same_v<T, uint32_t>) {
        printf("%s: %d, 0x%X\n", name.data(), value, value);
    } else if constexpr (std::is_same_v<T, uint64_t>) {
        printf("%s: %ld, 0x%lX\n", name.data(), value, value);
    }
}

template<typename T>
void print(std::string_view name, T value, ValueToString<T> fn) {
    auto text = fn ? fn(value) : "";
    if constexpr (std::is_same_v<T, uint8_t> || std::is_same_v<T, uint16_t> || std::is_same_v<T, uint32_t>) {
        printf("%s: %s (%d, 0x%X)\n", name.data(), text.cbegin(), value, value);
    } else if constexpr (std::is_same_v<T, uint64_t>) {
        printf("%s: %s (%ld, 0x%lX)\n", name.data(), text.cbegin(), value, value);
    }
}

void dumpHeader(std::ifstream& fs) {
    printf("===== ELF Header =====\n");

    auto identMagic = read<uint8_t, 4>(fs);
    auto identMagicText = std::vector(identMagic.begin(), identMagic.end());
    identMagicText.emplace_back('\0');
    printf(
        "Magic: %s (0x%X%X%X%X)\n",
        reinterpret_cast<char*>(identMagicText.data()),
        identMagic[0], identMagic[1], identMagic[2], identMagic[3]);

    auto identClass = read<uint8_t>(fs);
    print("Class", identClass, ValueToString<uint8_t>(classToString));

    auto ident_data = read<uint8_t>(fs);
    print("Data", ident_data, ValueToString<uint8_t>(dataToString));

    auto identVersion = read<uint8_t>(fs);
    ValueToString<uint8_t> identVersionToString = [](uint8_t v) -> std::string_view {
        return v == EV_CURRENT ? "Current" : "Unknown";
    };
    print("Version", identVersion, identVersionToString);

    auto identOSABI = read<uint8_t>(fs);
    print("OS/ABI", identOSABI, ValueToString<uint8_t>(osabiToString));

    auto identABIVersion = read<uint8_t>(fs);
    print("ABI Version", identABIVersion);

    read<uint8_t, 6>(fs);  // padding
    read<uint8_t>(fs);     // e_ident size

    assert(fs.tellg() == EI_NIDENT);

    auto type = read<uint16_t>(fs);
    print("Type", type, ValueToString<uint16_t>(elfTypeToString));

    auto machine = read<uint16_t>(fs);
    print("Machine", machine, ValueToString<uint16_t>(machineToString));

    auto version = read<uint32_t>(fs);
    print("Version", version);

    auto entry = read<uint64_t>(fs);
    print("Entry Point Address (e_entry)", entry);

    auto programHeaderOffset = read<uint64_t>(fs);
    print("Program Header Offset", programHeaderOffset);

    auto sectionHeaderOffset = read<uint64_t>(fs);
    print("Section Header Offset", sectionHeaderOffset);

    auto flags = read<uint32_t>(fs);
    print("Flags", flags);

    auto elfHeaderSize = read<uint16_t>(fs);
    print("ELF Header Size", elfHeaderSize);

    auto programHeaderEntrySize = read<uint16_t>(fs);
    print("Program Header Entry Size", programHeaderEntrySize);

    auto programHeaderEntryCount = read<uint16_t>(fs);
    print("Program Header Entry Count", programHeaderEntryCount);

    auto sectionHeaderEntrySize = read<uint16_t>(fs);
    print("Section Header Entry Size", sectionHeaderEntrySize);

    auto sectionHeaderEntryCount = read<uint16_t>(fs);
    print("Section Header Entry Count", sectionHeaderEntryCount);

    auto sectionHeaderStringTableIndex = read<uint16_t>(fs);
    print("Section Header String Table Index", sectionHeaderStringTableIndex);

    assert(fs.tellg() == programHeaderOffset);

    printf("\n");
    printf("===== Program Header =====\n");

    // MEMO: PT_LOAD は必ず連続して配置されている
    uint64_t loadAddressRangeStart = UINT64_MAX;
    uint64_t loadAddressRangeEnd = 0;
    for (int i = 0; i < programHeaderEntryCount; i++) {
        printf("- - - Segment %d - - -\n", i);

        auto type = read<uint32_t>(fs);
        print("Type", type, ValueToString<uint32_t>(programTypeToString));

        auto flags = read<uint32_t>(fs);
        print("Flags", flags);

        auto offset = read<uint64_t>(fs);
        print("Offset", offset);

        auto virtualAddress = read<uint64_t>(fs);
        print("Virtual Address", virtualAddress);

        auto physicalAddress = read<uint64_t>(fs);
        print("Pysical Address", physicalAddress);

        auto fileSize = read<uint64_t>(fs);
        print("File Size", fileSize);

        auto memorySize = read<uint64_t>(fs);
        print("Memory Size", memorySize);

        auto alignment = read<uint64_t>(fs);
        print("Alignment", alignment);

        if (type == PT_LOAD) {
            if (fileSize > memorySize) {
                printf("壊れています。理由: PT_LOAD && p_filesz > p_memsz\n");
                continue;
            }
            loadAddressRangeStart = std::min(loadAddressRangeStart, virtualAddress);
            loadAddressRangeEnd = std::max(loadAddressRangeEnd, virtualAddress + memorySize);
        }
    }

    printf("- - -\n");
    print("Load Address Range Start", loadAddressRangeStart);
    print("Load Address Range End", loadAddressRangeEnd);

    assert(fs.tellg() == programHeaderOffset + programHeaderEntrySize * programHeaderEntryCount);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("ファイル名を指定してください。\n");
        return EXIT_FAILURE;
    }

    std::vector<std::string> args(argv, argv + argc);
    assert(argc == args.size());
    auto fileName = args[1];
    printf("%s\n", fileName.c_str());
    std::ifstream stream(fileName, std::ios::binary);

    if (!stream.is_open()) {
        printf("\"%s\" はオープンできませんでした。\n", fileName.c_str());
        return EXIT_FAILURE;
    }

    if (stream.fail()) {
        stream.close();
        return EXIT_FAILURE;
    }

    dumpHeader(stream);

    stream.close();
    return EXIT_SUCCESS;
}
