#!/bin/bash -ex

sudo apt update
sudo apt upgrade
sudo apt install -y ansible

# https://astherier.com/blog/2020/08/run-gui-apps-on-wsl2/
sudo apt install libgl1-mesa-dev xorg-dev

pushd ~
git clone https://github.com/uchan-nos/mikanos-build.git osbook

cd devenv
ansible-playbook -K -i ansible_inventory ansible_provision.yml

popd # ~
