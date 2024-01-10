#pragma once

#include <elf.h>
#include <string_view>

std::string_view classToString(uint8_t value) {
    switch (value) {
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
    switch (value) {
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

std::string_view elfTypeToString(uint16_t value) {
    switch (value) {
    case ET_NONE:
        return "None";
    case ET_REL:
        return "Relocatable";
    case ET_EXEC:
        return "Executable";
    case ET_DYN:
        return "Shared Object";
    case ET_CORE:
        return "Core";
    }

    if (value >= ET_LOOS && value <= ET_HIOS) {
        return "OS Specific";
    }

    if (value >= ET_LOPROC && value <= ET_HIPROC) {
        return "Processor Specific";
    }

    return "Unknown";
}

std::string_view machineToString(uint16_t value) {
    switch (value) {
    case EM_NONE:
        return "None";
    case EM_386:
        return "Intel 80386";
    case EM_ARM:
        return "ARM";
    case EM_X86_64:
        return "AMD X86-64";
    case EM_AARCH64:
        return "AArch64";
    case EM_RISCV:
        return "RISC-V";
    default:
        return "Unknown";
    }
}

std::string_view programTypeToString(uint32_t value) {
    switch (value) {
    case PT_NULL:
        return "NULL";
    case PT_LOAD:
        return "Load";
    case PT_DYNAMIC:
        return "Dynamic Link";
    case PT_INTERP:
        return "Interpeter";
    case PT_NOTE:
        return "Note";
    case PT_PHDR:
        return "Program Header Table";
    case PT_TLS:
        return "Thread Local Storage";
    case PT_GNU_STACK:
        return "GNU Stack";
    default:
        return "Unknown";
    }
}