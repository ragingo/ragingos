#include <elf.h>
#include <stdio.h>
#include <algorithm>
#include <array>
#include <fstream>
#include <iostream>
#include <string>
#include <string_view>
#include <vector>

std::string_view classToString(uint8_t value) {
    switch (value)
    {
    case ELFCLASSNONE:
        return "NONE";
    case ELFCLASS32:
        return "ELF32";
    case ELFCLASS64:
        return "ELF64";
    default:
        return "Unknown";
    }
}

std::string_view dataToString(uint8_t value) {
    switch (value)
    {
    case ELFDATANONE:
        return "NONE";
    case ELFDATA2LSB:
        return "Little Endian";
    case ELFDATA2MSB:
        return "Big Endian";
    default:
        return "";
    }
}

std::string_view osabiToString(uint8_t value) {
    switch (value) {
        case ELFOSABI_NONE:
            return "Unspecified";
        case ELFOSABI_HPUX:
            return "Hewlett-Packard HP-UX";
        case ELFOSABI_NETBSD:
            return "NetBSD";
        case ELFOSABI_LINUX:
            return "Linux";
        case ELFOSABI_SOLARIS:
            return "Sun Solaris";
        case ELFOSABI_AIX:
            return "AIX";
        case ELFOSABI_IRIX:
            return "IRIX";
        case ELFOSABI_FREEBSD:
            return "FreeBSD";
        case ELFOSABI_TRU64:
            return "Compaq TRU64 UNIX";
        case ELFOSABI_MODESTO:
            return "Novell Modesto";
        case ELFOSABI_OPENBSD:
            return "Open BSD";
        case ELFOSABI_ARM:
            return "ARM";
        case ELFOSABI_STANDALONE:
            return "Standalone";
        default:
            return "Unknown";
    }
}

void dump(const Elf64_Ehdr& header) {
    {
        std::array<uint8_t, 4> values = {
            header.e_ident[EI_MAG0],
            header.e_ident[EI_MAG1],
            header.e_ident[EI_MAG2],
            header.e_ident[EI_MAG3]
        };
        printf(
            "Magic: %4s (0x%X%X%X%X)\n",
            reinterpret_cast<char*>(values.data()),
            values[0], values[1], values[2], values[3]
        );
    }
    {
        uint8_t value = header.e_ident[EI_CLASS];
        printf("Class: %s (%d)\n", classToString(value).cbegin(), value);
    }
    {
        uint8_t value = header.e_ident[EI_DATA];
        printf("Data: %s (%d)\n", dataToString(value).cbegin(), value);
    }
    {
        uint8_t value = header.e_ident[EI_VERSION];
        std::string_view value_sv = value == EV_CURRENT ? "Current" : "Unknown";
        printf("Version: %s (%d)\n", value_sv.cbegin(), value);
    }
    {
        uint8_t value = header.e_ident[EI_OSABI];
        printf("OS/ABI: %s (%d)\n", osabiToString(value).cbegin(), value);
    }
    printf("ABI Version: %d\n", header.e_ident[EI_ABIVERSION]);
    printf("Pad Start: %d\n", header.e_ident[EI_PAD]);
    printf("e_ident Size: %d\n", header.e_ident[EI_NIDENT]);
}

int main(int argc, char* argv[]) {
    std::vector<std::string> args(argv, argv + argc);
    auto file_name = args[0];
    std::fstream stream { file_name, std::ios_base::in | std::ios_base::binary };

    if (!stream.is_open()) {
        printf("\"%s\" はオープンできなかった。\n", file_name.c_str());
        return EXIT_FAILURE;
    }

    stream.seekg(0, std::ios_base::beg);

    Elf64_Ehdr file_header = {0};
    stream.read(reinterpret_cast<char*>(&file_header), sizeof(Elf64_Ehdr));

    if (stream.fail()) {
        stream.close();
        return EXIT_FAILURE;
    }

    stream.close();
    dump(file_header);
    return EXIT_SUCCESS;
}
