#!/bin/bash -ex

# WSL2 Ubuntu 20.04 で動作確認した

sudo apt update
sudo apt upgrade

git clone https://github.com/uchan-nos/mikanos-build.git osbook
sudo apt install -y ansible
pushd osbook/devenv
ansible-playbook -K -i ansible_inventory ansible_provision.yml
popd
iasl -v
ls ~/edk2
source ~/.profile

mkdir workspace
pushd workspace
git clone https://github.com/uchan-nos/mikanos.git
popd

# day02 あたりが終わったら差し替え
pushd edk2
ln -s $HOME/ragingos/src/RagingosLoaderPkg ./
ls RagingosLoaderPkg/main.c
source edksetup.sh
vi Conf/target.txt
build
ls Build/RagingosLoaderX64/DEBUG_CLANG38/X64/Loader.efi
popd