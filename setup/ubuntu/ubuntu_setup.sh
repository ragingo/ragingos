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
