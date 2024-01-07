#!/bin/bash -eux

clang++ -std=c++2a -O2 -Wall -o elf_checker main.cpp
./elf_checker ~/ragingos/build/kernel/kernel.elf
