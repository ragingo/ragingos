#include <elf.h>
#include <stdio.h>
#include <array>
#include <cassert>
#include <fstream>
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

uint64_t calcEntryPointAddress(const Elf64_Ehdr& header) {
    uint64_t entry = 0;
    auto programHeader = reinterpret_cast<const Elf64_Phdr*>(reinterpret_cast<const uint8_t*>(&header) + header.e_phoff);

    printf("[aaa] %d \n", header.e_phnum);
    for (int i = 0; i < header.e_phnum; i++) {
        auto ph = programHeader[i];
        if (ph.p_type != PT_LOAD) {
            printf("[aaa] not load \n");
            continue;
        }
        printf("[aaa] entry %lX vs vaddr %lX \n", entry, ph.p_vaddr);
        entry = std::min(entry, ph.p_vaddr);
    }

    return entry;
}

void dump(std::ifstream& fs) {
    auto ident_magic = read<uint8_t, 4>(fs);
    auto ident_magic_text = std::vector(ident_magic.begin(), ident_magic.end());
    ident_magic_text.emplace_back('\0');
    printf(
        "Magic: %s (0x%X%X%X%X)\n",
        reinterpret_cast<char*>(ident_magic_text.data()),
        ident_magic[0], ident_magic[1], ident_magic[2], ident_magic[3]);

    auto ident_class = read<uint8_t>(fs);
    printf("Class: %s (%d)\n", classToString(ident_class).cbegin(), ident_class);

    auto ident_data = read<uint8_t>(fs);
    printf("Data: %s (%d)\n", dataToString(ident_data).cbegin(), ident_data);

    auto ident_version = read<uint8_t>(fs);
    std::string_view ident_version_text = ident_version == EV_CURRENT ? "Current" : "Unknown";
    printf("Version: %s (%d)\n", ident_version_text.cbegin(), ident_version);

    auto ident_osabi = read<uint8_t>(fs);
    printf("OS/ABI: %s (%d)\n", osabiToString(ident_osabi).cbegin(), ident_osabi);

    auto ident_abiVersion = read<uint8_t>(fs);
    printf("ABI Version: %d\n", ident_abiVersion);

    read<uint8_t, 6>(fs);  // padding
    read<uint8_t>(fs);     // e_ident size

    assert(fs.tellg() == EI_NIDENT);

    auto type = read<uint16_t>(fs);
    printf("Type: %s (%d)\n", typeToString(type).cbegin(), type);

    auto machine = read<uint16_t>(fs);
    printf("Machine: %s (%d)\n", machineToString(machine).cbegin(), machine);

    auto version = read<uint32_t>(fs);
    printf("Version: %d\n", version);

    auto entry = read<uint64_t>(fs);
    printf("Entry Point Address (e_entry): 0x%lX\n", entry);

    auto programHeaderOffset = read<uint64_t>(fs);
    printf("Program Header Offset: %lu bytes (0x%lX)\n", programHeaderOffset, programHeaderOffset);

    auto sectionHeaderOffset = read<uint64_t>(fs);
    printf("Section Header Offset: %lu bytes (0x%lX)\n", sectionHeaderOffset, sectionHeaderOffset);

    auto flags = read<uint32_t>(fs);
    printf("Flags: 0x%X\n", flags);

    auto elfHeaderSize = read<uint16_t>(fs);
    printf("ELF Header Size: %u bytes (0x%X)\n", elfHeaderSize, elfHeaderSize);

    auto programHeaderEntrySize = read<uint16_t>(fs);
    printf("Program Header Entry Size: %u bytes (0x%X)\n", programHeaderEntrySize, programHeaderEntrySize);

    auto programHeaderEntryCount = read<uint16_t>(fs);
    printf("Program Header Entry Count: %u (0x%X)\n", programHeaderEntryCount, programHeaderEntryCount);

    auto sectionHeaderEntrySize = read<uint16_t>(fs);
    printf("Section Header Entry Size: %u bytes (0x%X)\n", sectionHeaderEntrySize, sectionHeaderEntrySize);

    auto sectionHeaderEntryCount = read<uint16_t>(fs);
    printf("Section Header Entry Count: %u (0x%X)\n", sectionHeaderEntryCount, sectionHeaderEntryCount);

    auto sectionHeaderStringTableIndex = read<uint16_t>(fs);
    printf("Section Header String Table Index: %u (0x%X)\n", sectionHeaderStringTableIndex, sectionHeaderStringTableIndex);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("ファイル名を指定してください。\n");
        return EXIT_FAILURE;
    }

    std::vector<std::string> args(argv, argv + argc);
    assert(argc == args.size());
    auto file_name = args[1];
    printf("%s\n", file_name.c_str());
    std::ifstream stream(file_name, std::ios::binary);

    if (!stream.is_open()) {
        printf("\"%s\" はオープンできませんでした。\n", file_name.c_str());
        return EXIT_FAILURE;
    }

    if (stream.fail()) {
        stream.close();
        return EXIT_FAILURE;
    }

    dump(stream);

    stream.close();
    return EXIT_SUCCESS;
}
