#!/bin/bash -eux

g++ -std=c++2a -Wall -o elf_checker main.cpp
./elf_checker ~/ragingos/build/kernel/kernel.elf
