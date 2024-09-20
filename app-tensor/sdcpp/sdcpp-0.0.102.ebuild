# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
LLVM_COMPAT=( 18 )
ROCM_VERSION="6.1.1"

inherit cuda rocm git-r3 llvm-r1 cmake

DESCRIPTION="Stable Diffusion and Flux in pure C/C++"
HOMEPAGE="https://github.com/leejet/stable-diffusion.cpp"

EGIT_REPO_URI="https://github.com/leejet/stable-diffusion.cpp.git"
EGIT_COMMIT="master-e410aeb"

KEYWORDS="~amd64 ~arm64"
LICENSE="MIT"
SLOT="0"
IUSE="flash-attenuation softmax cuda hip vulkan"
RESTRICT="test"

REQUIRED_USE="
	^^ ( hip cuda )
	softmax? ( cuda )
"

RDEPEND="
	hip? (
		>=sci-libs/hipBLAS-6.1.1:=
		$(llvm_gen_dep '
			>=dev-util/hip-6.1.1:=[llvm_slot_${LLVM_SLOT}]
		')
	)
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	vulkan? (
		dev-util/vulkan-headers
		media-libs/vulkan-loader
	)
"

DEPEND="${RDEPEND}
	dev-cpp/eigen:=
"

BDEPEND="
	vulkan? (
		dev-util/vulkan-headers
	)
"

src_prepare() {
	default

	if use cuda; then
		cuda_src_prepare
	fi

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D SD_BUILD_EXAMPLES=ON
		-D SD_CUBLAS=$(usex cuda)
		-D SD_HIPBLAS=$(usex hip)
		-D SD_VULKAN=$(usex vulkan)
		-D SD_SYCL=OFF # todo figure out sycl support / $(usex sycl)
		-D SD_FLASH_ATTN=$(usex flash-attenuation)
		-D SD_FAST_SOFTMAX=$(usex softmax)
		-D SD_BUILD_SHARED_LIBS=ON
		-D CMAKE_HIP_COMPILER_ROCM_ROOT="${EPREFIX}/usr"
	)

	if use cuda; then
		addwrite /dev/nvidiactl
	fi

	if use hip; then
		addwrite /dev/kfd
		addwrite /dev/dri
	fi

	cmake_src_configure
}

src_install() {
	cd $BUILD_DIR
	dobin bin/sd
	dolib.so bin/libstable-diffusion.so
}
