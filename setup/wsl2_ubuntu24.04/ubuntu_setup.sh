#!/bin/bash -ex

sudo apt update
sudo apt upgrade -y
sudo apt install -y ansible

curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/llvm.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble main" | sudo tee /etc/apt/sources.list.d/llvm.list > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-19 main" | sudo tee -a /etc/apt/sources.list.d/llvm.list > /dev/null

ansible-playbook -K -i ansible_inventory ansible_provision.yml
iasl -v
