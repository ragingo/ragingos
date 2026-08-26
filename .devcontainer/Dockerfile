FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-x86-64-linux-gnu g++-x86-64-linux-gnu libc6-dev-amd64-cross \
    wget curl git make cmake ninja-build automake libtool \
    nasm \
    acpica-tools uuid-dev \
    libc6-dev-amd64-cross \
    qemu-system-x86 qemu-utils \
    dosfstools mtools \
    lsb-release software-properties-common gnupg2 \
    gdb rsync unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# clang/lld/llvm-ar (apt.llvm.org は arm64 リポジトリも配布)
RUN wget https://apt.llvm.org/llvm.sh \
    && chmod +x llvm.sh \
    && ./llvm.sh 22 all \
    && rm llvm.sh \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-22 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-22 100 \
    && update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-22 100 \
    && update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-22 100

# update-alternatives で objcopy の実体を llvm-objcopy-22 に上書きする
RUN update-alternatives --install /usr/bin/objcopy objcopy /usr/bin/llvm-objcopy-22 100

RUN rm -f /etc/profile.d/debuginfod.sh

CMD ["/bin/bash"]
