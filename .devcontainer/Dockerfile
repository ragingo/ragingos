FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-x86-64-linux-gnu g++-x86-64-linux-gnu libc6-dev-amd64-cross \
    wget curl git make cmake ninja-build automake libtool \
    acpica-tools uuid-dev \
    libc6-dev-amd64-cross \
    qemu-system-x86 qemu-utils \
    dosfstools mtools \
    lsb-release software-properties-common gnupg2 \
    gdb rsync unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# NASMはaptの3.01系がEDK2のUefiCpuPkg等と非互換のため、
# ソースから2.16.03（EDK2で広く使われている安定版）をビルドして固定する
RUN wget https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/nasm-2.16.03.tar.gz \
    && tar xzf nasm-2.16.03.tar.gz \
    && cd nasm-2.16.03 \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf nasm-2.16.03 nasm-2.16.03.tar.gz \
    && nasm --version   # ビルド時点で 2.16.03 になっているか確認

# clang/lld/llvm-ar (apt.llvm.org は arm64 リポジトリも配布)
RUN wget https://apt.llvm.org/llvm.sh \
    && chmod +x llvm.sh \
    && ./llvm.sh 22 all \
    && rm llvm.sh \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-22 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-22 100 \
    && update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-22 100 \
    && update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-22 100

RUN update-alternatives --install /usr/bin/objcopy objcopy /usr/bin/llvm-objcopy-22 100

RUN rm -f /etc/profile.d/debuginfod.sh

CMD ["/bin/bash"]
