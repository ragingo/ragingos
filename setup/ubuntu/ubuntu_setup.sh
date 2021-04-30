#!/bin/bash -ex

sudo apt update
sudo apt upgrade
sudo apt qemu-utils # qemu-img
sudo apt qemu-system # qemu-system-x86_64

# https://astherier.com/blog/2020/08/run-gui-apps-on-wsl2/
sudo apt install libgl1-mesa-dev xorg-dev
