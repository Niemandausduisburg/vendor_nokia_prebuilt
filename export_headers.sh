#!/bin/bash

# this uses the mcd-clang toolchain
# https://github.com/mcdachpappe/mcd-clang
# when building under WSL make sure the distro uses WSL 2

TOOLCHAIN_DIR="$(pwd)/clang"

# Path to executables in Clang toolchain
clang_path="${TOOLCHAIN_DIR}"
clang_bin="${clang_path}/bin"

# 64-bit GCC toolchain prefix
gcc_prefix64="${clang_bin}/aarch64-linux-gnu-"

# 32-bit GCC toolchain prefix
gcc_prefix32="${clang_bin}/arm-linux-gnueabi-"

export PATH="${clang_bin}:${PATH}"
ARCH=arm64
KERNEL_OUTPUT="$(pwd)/out2"
DEFCONFIG=${DEFCONFIG:-nb1_defconfig}

KERNEL_OUTPUT=$(readlink -f ${KERNEL_OUTPUT})

	echo "Cleaning output dir"
	rm -rf ${KERNEL_OUTPUT}
	make clean && make mrproper
	mkdir -p ${KERNEL_OUTPUT}


	echo "Making config"
	make O=${KERNEL_OUTPUT} ARCH=${ARCH} ${DEFCONFIG}


	echo "Build kernel"

	THREADS=$(nproc --all)

	kmake_flags=(
		-j"${THREADS}"
		ARCH="${ARCH}"
		O="${KERNEL_OUTPUT}"
		CC="ccache clang"
		AS="llvm-as"
		AR="llvm-ar"
		NM="llvm-nm"
		OBJCOPY="llvm-objcopy"
		OBJDUMP="llvm-objdump"
		STRIP="llvm-strip"
		CROSS_COMPILE="${gcc_prefix64}"
		CROSS_COMPILE_ARM32="${gcc_prefix32}"
		LOCALVERSION="${LOCALVERSION}"
	)

	 make headers_install ARCH=arm64 INSTALL_HDR_PATH=out2
