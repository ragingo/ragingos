#include <elf.h>
#include <stdio.h>
#include <algorithm>
#include <array>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

void dump(const Elf64_Ehdr& header) {
    std::array<uint8_t, 4> magic_expect = { ELFMAG0, ELFMAG1, ELFMAG2, ELFMAG3 };
    std::array<uint8_t, 4> magic_actual = {
        header.e_ident[EI_MAG0],
        header.e_ident[EI_MAG1],
        header.e_ident[EI_MAG2],
        header.e_ident[EI_MAG3]
    };
    auto magic_result = magic_expect == magic_actual ? "OK" : "NG";
    printf(
        "magic: %4s (%X, %X, %X, %X) [%s]\n",
        reinterpret_cast<char*>(magic_actual.data()),
        magic_actual[0], magic_actual[1], magic_actual[2], magic_actual[3],
        magic_result
    );

    std::array<uint8_t, 3> class_expected = { ELFCLASSNONE, ELFCLASS32, ELFCLASS64 };
    uint8_t class_actual = header.e_ident[EI_CLASS];
    auto class_result = std::count(class_expected.begin(), class_expected.end(), class_actual) > 0 ? "OK" : "NG";
    printf("class: %d [%s]\n", class_actual, class_result);
}

int main(int argc, char* argv[]) {
    std::vector<std::string> args(argv, argv + argc);
    auto file_name = args[0];
    std::fstream stream { file_name, std::ios_base::in | std::ios_base::binary };
    stream.seekg(0, std::ios_base::beg);

    Elf64_Ehdr file_header = {0};
    stream.read(reinterpret_cast<char*>(&file_header), sizeof(Elf64_Ehdr));

    dump(file_header);

    return EXIT_SUCCESS;
}
