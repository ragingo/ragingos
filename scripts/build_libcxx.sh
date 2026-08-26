#!/bin/bash -eux

# BUILD_MODE
# - CLONE_AND_BUILD
# - CLEAN_BUILD
# - INCREMENTAL_BUILD
BUILD_MODE=CLEAN_BUILD

LLVM_VERSION=22.1.8
LLVM_TAG=llvmorg-$LLVM_VERSION

CC=clang
CXX=clang++
LD=ld.lld
TARGET_TRIPLE=x86_64-elf
NEWLIB_INCLUDES="$(realpath ./lib/newlib_build/$TARGET_TRIPLE/include)"

pushd ./lib

if [ "$BUILD_MODE" == "CLONE_AND_BUILD" ]; then
  rm -rf ./llvm
  rm -rf ./llvm_runtimes_build
  git clone --depth=1 -b $LLVM_TAG https://github.com/llvm/llvm-project.git llvm

  mkdir -p llvm_runtimes_build
fi

CXX_FLAGS="\
  -nostdlibinc \
  -O2 \
  -D__ELF__ \
  -D_GNU_SOURCE \
  -D_LDBL_EQ_DBL \
  -D_POSIX_TIMERS \
  -D_LIBCPP_PROVIDES_DEFAULT_RUNE_TABLE \
  -mcmodel=large \
"

#====================================
# libcxx & libcxxabi Unified Build
#====================================
pushd llvm_runtimes_build

if [ "$BUILD_MODE" == "CLEAN_BUILD" ]; then
  rm -rf CMakeCache.txt CMakeFiles || true
fi

cmake -G Ninja \
  -S ../llvm/runtimes \
  -B . \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_C_COMPILER_TARGET=$TARGET_TRIPLE \
  -DCMAKE_C_FLAGS="$CXX_FLAGS -I$NEWLIB_INCLUDES" \
  -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_CXX_COMPILER_TARGET=$TARGET_TRIPLE \
  -DCMAKE_CXX_FLAGS="$CXX_FLAGS -I$NEWLIB_INCLUDES -std=c++23" \
  -DCMAKE_LINKER=$LD \
  -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
  -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
  -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
  -DLIBCXX_ENABLE_RTTI=OFF \
  -DLIBCXX_ENABLE_SHARED=OFF \
  -DLIBCXXABI_ENABLE_SHARED=OFF \
  -DLIBCXX_ENABLE_STATIC=ON \
  -DLIBCXXABI_ENABLE_STATIC=ON \
  -DLIBCXX_ENABLE_THREADS=OFF \
  -DLIBCXXABI_ENABLE_THREADS=OFF \
  -DLIBCXX_HAS_THREAD_API=OFF \
  -DLIBCXXABI_HAS_THREAD_API=OFF \
  -DLIBCXX_ENABLE_LOCALIZATION=ON \
  -DLIBCXX_ENABLE_FILESYSTEM=OFF \
  -DLIBCXX_ENABLE_TIME_ZONE_DATABASE=OFF \
  -DLIBCXX_ENABLE_MONOTONIC_CLOCK=OFF \
  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
  -DLIBCXX_INCLUDE_TESTS=OFF \
  -DLIBCXXABI_INCLUDE_TESTS=OFF \
  -DLIBCXXABI_USE_LLVM_UNWINDER=OFF

ninja -j$(nproc) cxx cxxabi

popd

popd