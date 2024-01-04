#!/bin/bash -eux

g++ -o elf_checker main.cpp
./elf_checker ~/ragingos/build/kernel/kernel.elf
