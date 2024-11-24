#!/bin/bash -eux

# BUILD_MODE
# - CLONE_AND_BUILD
# - CLEAN_BUILD
# - INCREMENTAL_BUILD
BUILD_MODE=CLEAN_BUILD

LLVM_VERSION=19.1.4
LLVM_TAG=llvmorg-$LLVM_VERSION

CC=clang
CXX=clang++
LD=ld.lld
TARGET_TRIPLE=x86_64-elf
NEWLIB_INCLUDES="$(realpath ./lib/newlib_build/$TARGET_TRIPLE/include)"

pushd ./lib

if [ $BUILD_MODE == "CLONE_AND_BUILD" ]; then
  rm -rf ./llvm
  rm -rf ./llvm_libcxxabi_build
  rm -rf ./llvm_libcxx_build
  git clone --depth=1 -b $LLVM_TAG https://github.com/llvm/llvm-project.git llvm

  pushd llvm
  git apply ../../scripts/llvm_libcxxabi_src_CMakeLists_disable-cxxabi-test-depends.patch
  popd

  mkdir llvm_libcxxabi_build
  mkdir llvm_libcxx_build
fi

CXX_FLAGS="\
  -nostdlibinc \
  -O2 \
  -D__ELF__ \
  -D__GLIBC_USE\(...\)=0 \
  -D_GNU_SOURCE \
  -D_LDBL_EQ_DBL \
  -D_LIBCPP_HAS_NO_MONOTONIC_CLOCK \
  -D_LIBCPP_HAS_NO_THREADS \
  -D_POSIX_TIMERS \
  -DDISABLE_THREADS \
  -mcmodel=large \
"

#====================
# libcxxabi build
#====================
pushd llvm_libcxxabi_build
mkdir -p include

if [ $BUILD_MODE == "CLEAN_BUILD" ]; then
  rm cmake_install.cmake || true
  rm CMakeCache.txt || true
  rm ./lib/libc++abi.a || true
fi

CXX_INCLUDES="\
  -I$(realpath ../llvm/libcxx/include/c++/v1) \
  -I$(realpath ../llvm/libcxx/include) \
  -I/usr/include/c++/v1 \
  -I$NEWLIB_INCLUDES \
  -I/usr/include \
"

# NOTE:
# - CMAKE_INSTALL_PREFIX を設定しても効果がない
cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_C_COMPILER_TARGET=$TARGET_TRIPLE \
  -DCMAKE_C_FLAGS="$CXX_INCLUDES $CXX_FLAGS" \
  -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_CXX_COMPILER_TARGET=$TARGET_TRIPLE \
  -DCMAKE_CXX_FLAGS="$CXX_INCLUDES $CXX_FLAGS -std=c++23" \
  -DCMAKE_LINKER=$LD \
  -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
  -DLIBCXXABI_ENABLE_EXCEPTIONS=False \
  -DLIBCXXABI_ENABLE_SHARED=False \
  -DLIBCXXABI_ENABLE_STATIC=True \
  -DLIBCXXABI_ENABLE_THREADS=False \
  -DLIBCXXABI_INCLUDE_TESTS=False \
  -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
  ../llvm/libcxxabi

ninja -j$(nproc)

popd

#====================
# libcxx build
#====================
pushd llvm_libcxx_build

if [ $BUILD_MODE == "CLEAN_BUILD" ]; then
  rm cmake_install.cmake || true
  rm CMakeCache.txt || true
  rm ./lib/libc++.a || true
  rm ./lib/libc++experimental.a || true
fi

CXX_ABI_DIR="$(realpath ../llvm_libcxxabi_build)"

CXX_INCLUDES="\
  -I$CXX_ABI_DIR/include/c++/v1 \
  -I$CXX_ABI_DIR/include \
  -I$(realpath ./include/c++/v1) \
  -I$(realpath ./include) \
  -I$NEWLIB_INCLUDES \
"

cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_C_COMPILER_TARGET=$TARGET_TRIPLE \
  -DCMAKE_C_FLAGS="$CXX_INCLUDES $CXX_FLAGS" \
  -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_CXX_FLAGS="$CXX_INCLUDES $CXX_FLAGS -Wno-c++11-narrowing -std=c++23" \
  -DCMAKE_CXX_COMPILER_TARGET=$TARGET_TRIPLE \
  -DCMAKE_LINKER=$LD \
  -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_ENABLE_EXCEPTIONS=False \
  -DLIBCXX_ENABLE_FILESYSTEM=False \
  -DLIBCXX_ENABLE_RTTI=False \
  -DLIBCXX_ENABLE_SHARED=False \
  -DLIBCXX_ENABLE_STATIC=True \
  -DLIBCXX_ENABLE_THREADS=False \
  -DLIBCXX_INCLUDE_BENCHMARKS=False \
  -DLIBCXX_INCLUDE_TESTS=False \
  -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
  ../llvm/libcxx

cmake --build . --target cxx_static -- -j$(nproc)

popd

popd
