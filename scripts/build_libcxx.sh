#!/bin/bash -eux

LLVM_VERSION=19.1.0
LLVM_TAG=llvmorg-$LLVM_VERSION

CC=clang
CXX=clang++
LD=ld.lld
TARGET_TRIPLE=x86_64-elf
#CFLAGS="-nostdinc -nostdinc++ -nostdlibinc -O2 -D__ELF__ -D_LDBL_EQ_DBL -D_POSIX_TIMERS -fPIC -D_LIBCPP_HAS_NO_THREADS"
NEWLIB_INCLUDES="$(pwd)/lib/newlib_build/$TARGET_TRIPLE/include"

pushd ./lib
rm -rf ./llvm
rm -rf ./llvm_libcxxabi_build
rm -rf ./llvm_libcxx_build
git clone --depth=1 -b $LLVM_TAG https://github.com/llvm/llvm-project.git llvm

pushd llvm
git apply ../../scripts/llvm_libcxxabi_src_CMakeLists_disable-cxxabi-test-depends.patch
popd

mkdir llvm_libcxxabi_build
mkdir llvm_libcxx_build

#====================
# libcxxabi build
#====================
pushd llvm_libcxxabi_build
mkdir -p include
# cp -p /usr/include/c++/v1/__config_site ./include/
# cp -p ../llvm/libc/include/features.h.def ../llvm/libc/include/features.h
# cp -p /usr/include/features.h ./include/
# cp -p /usr/include/features-time64.h ./include/

rm cmake_install.cmake || true
rm CMakeCache.txt || true
# rm include/__config_site || true
rm ./lib/libc++abi.a || true

CXX_FLAGS="-nostdlibinc -O2 -D__ELF__ -D_LDBL_EQ_DBL -D_GNU_SOURCE -D_POSIX_TIMERS -D_LIBCPP_HAS_NO_THREADS -DDISABLE_THREADS -D_LIBCPP_HAS_NO_MONOTONIC_CLOCK -D__GLIBC_USE\(...\)=0"
CXX_INCLUDES="-I$(realpath ./include) -I$(realpath ./include/c++/v1) -I$(realpath ./include/llvm/Config) -I$(realpath ../llvm/libcxx/include) -I$(realpath ../llvm/llvm/include) -I$(realpath ../stdlib_build/x86_64-elf/include) -I/usr/include/c++/v1 -I/usr/include"

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_C_COMPILER_TARGET=$TARGET_TRIPLE \
    -DCMAKE_C_FLAGS="$CXX_INCLUDES $CXX_FLAGS" \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DCMAKE_CXX_COMPILER_TARGET=$TARGET_TRIPLE \
    -DCMAKE_CXX_FLAGS="$CXX_INCLUDES $CXX_FLAGS" \
    -DCMAKE_INSTALL_PREFIX="$(realpath ../stdlib_build/x86_64-elf)" \
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

# CMake Warning:
#   Manually-specified variables were not used by the project:

#     LIBCXXABI_TARGET_TRIPLE
#     LIBCXX_CXX_ABI
#     LIBCXX_CXX_ABI_INCLUDE_PATHS
#     LIBCXX_CXX_ABI_LIBRARY_PATH
#     LIBCXX_DEFAULT_ABI_LIBRARY
#     LIBCXX_ENABLE_EXCEPTIONS
#     LIBCXX_ENABLE_FILESYSTEM
#     LIBCXX_ENABLE_MONOTONIC_CLOCK
#     LIBCXX_ENABLE_RTTI
#     LIBCXX_ENABLE_SHARED
#     LIBCXX_ENABLE_STATIC_ABI_LIBRARY
#     LIBCXX_ENABLE_THREADS
#     LLVM_DEFAULT_TARGET_TRIPLE


ninja -C $(pwd)

# llvm でビルドするとどうしても LLVMSupport とか余計なビルドが走る。
# これを無効化するのは無理っぽいので、やっぱり個別ビルドするしかなさそう。
# cmake -G Ninja \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DCMAKE_C_COMPILER=$CC \
#     -DCMAKE_C_COMPILER_TARGET=$TARGET_TRIPLE \
#     -DCMAKE_C_FLAGS="$CXX_INCLUDES $CXX_FLAGS" \
#     -DCMAKE_CXX_COMPILER=$CXX \
#     -DCMAKE_CXX_COMPILER_TARGET=$TARGET_TRIPLE \
#     -DCMAKE_CXX_FLAGS="$CXX_INCLUDES $CXX_FLAGS" \
#     -DCMAKE_INSTALL_PREFIX="$(realpath ../stdlib_build/x86_64-elf)" \
#     -DCMAKE_LINKER=$LD \
#     -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
#     -DHAVE_CXX_ATOMICS_WITHOUT_LIB=True \
#     -DHAVE_CXX_ATOMICS64_WITHOUT_LIB=True \
#     -DLIBCXX_CXX_ABI=libcxxabi \
#     -DLIBCXX_CXX_ABI_INCLUDE_PATHS="$(realpath ../llvm/libcxxabi/include)" \
#     -DLIBCXX_CXX_ABI_LIBRARY_PATH="$(realpath ../stdlib_build/x86_64-elf/lib)" \
#     -DLIBCXX_DEFAULT_ABI_LIBRARY=libcxxabi \
#     -DLIBCXX_ENABLE_EXCEPTIONS=False \
#     -DLIBCXX_ENABLE_FILESYSTEM=False \
#     -DLIBCXX_ENABLE_MONOTONIC_CLOCK=False \
#     -DLIBCXX_ENABLE_RTTI=False \
#     -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=True \
#     -DLIBCXX_ENABLE_SHARED=False \
#     -DLIBCXX_ENABLE_THREADS=False \
#     -DLIBCXXABI_TARGET_TRIPLE=$TARGET_TRIPLE \
#     -DLIBCXXABI_ENABLE_EXCEPTIONS=False \
#     -DLIBCXXABI_ENABLE_SHARED=False \
#     -DLIBCXXABI_ENABLE_STATIC=True \
#     -DLIBCXXABI_ENABLE_THREADS=False \
#     -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
#     -DLLVM_DEFAULT_TARGET_TRIPLE=$TARGET_TRIPLE \
#     -DLLVM_ENABLE_LIBCXX=True \
#     -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
#     -DLLVM_LIBC_FULL_BUILD=True \
#     -DLLVM_TARGETS_TO_BUILD=X86 \
#     -DLLVM_ENABLE_THREADS=True \
#     -DLLVM_HAS_ATOMICS=True \
#     -DHAVE_SYSEXITS_H=1 \
#     -DLLVM_INCLUDE_EXAMPLES=False \
#     -DLLVM_BUILD_EXAMPLES=False \
#     -DLLVM_INCLUDE_TESTS=False \
#     -DLLVM_BUILD_TESTS=False \
#     -DLLVM_INCLUDE_DOCS=False \
#     -DLLVM_BUILD_DOCS=False \
#     -DLLVM_INCLUDE_BENCHMARKS=False \
#     -DLLVM_BUILD_BENCHMARKS=False \
#   ../llvm/llvm

# ninja -C $(pwd) cxxabi cxx

popd

#====================
# libcxx build
#====================
# pushd llvm_libcxx_build

# cmake -G "Unix Makefiles" \
#   -DCMAKE_INSTALL_PREFIX=$(pwd) \
#   -DCMAKE_CXX_COMPILER=$CXX \
#   -DCMAKE_CXX_FLAGS="-I$(pwd)/include $CFLAGS" \
#   -DCMAKE_CXX_COMPILER_TARGET=$TARGET_TRIPLE \
#   -DCMAKE_C_COMPILER=$CC \
#   -DCMAKE_C_FLAGS="-I$(pwd)/include $CFLAGS" \
#   -DCMAKE_C_COMPILER_TARGET=$TARGET_TRIPLE \
#   -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
#   -DCMAKE_BUILD_TYPE=Release \
#   -DLIBCXX_CXX_ABI=libcxxabi \
#   -DLIBCXX_CXX_ABI_INCLUDE_PATHS="$(realpath ../llvm/libcxxabi/include)" \
#   -DLIBCXX_CXX_ABI_LIBRARY_PATH="$(realpath ../llvm/libcxxabi/lib)" \
#   -DLIBCXX_ENABLE_EXCEPTIONS=False \
#   -DLIBCXX_ENABLE_FILESYSTEM=False \
#   -DLIBCXX_ENABLE_MONOTONIC_CLOCK=False \
#   -DLIBCXX_ENABLE_RTTI=False \
#   -DLIBCXX_ENABLE_THREADS=False \
#   -DLIBCXX_ENABLE_SHARED=False \
#   -DLIBCXX_ENABLE_STATIC=True \
#   ../llvm/libcxx

# make -j$(nproc)
# make install

# popd

popd
