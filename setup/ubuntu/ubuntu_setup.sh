#!/bin/bash -ex

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

pushd edk2
ln -s $HOME/workspace/mikanos/MikanLoaderPkg ./
ls MikanLoaderPkg/Main.c
source edksetup.sh
vi Conf/target.txt
build
ls Build/MikanLoaderX64/DEBUG_CLANG38/X64/Loader.efi
popd

source $HOME/osbook/devenv/buildenv.sh
pushd $HOME/workspace/mikanos
./build.sh
./build.sh run
popd
