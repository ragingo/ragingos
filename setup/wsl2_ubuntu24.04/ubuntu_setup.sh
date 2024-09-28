#!/bin/bash -ex

sudo apt update
sudo apt upgrade -y
sudo apt install -y ansible
ansible-playbook -K -i ansible_inventory ansible_provision.yml
iasl -v
