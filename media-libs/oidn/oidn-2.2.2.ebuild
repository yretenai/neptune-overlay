# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO(???): Check CUDA, I (Ada) do not have a CUDA-capable GPU to test this on.
# TODO(ada): Fix AMDGPU_TARGETS being hardcoded -> https://github.com/OpenImageDenoise/oidn/blob/v2.1.0/devices/hip/CMakeLists.txt#L24-L29
# TODO(ada): Only use openimageio if examples is also set.

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )
LLVM_MAX_SLOT=17
ROCM_VERSION="5.7.1"

inherit rocm cuda cmake python-single-r1 llvm

DESCRIPTION="Intel(R) Open Image Denoise library"
HOMEPAGE="https://www.openimagedenoise.org/"

if [[ ${PV} = *9999 ]]; then
	EGIT_REPO_URI="https://github.com/OpenImageDenoise/oidn.git"
	EGIT_BRANCH="master"
	inherit git-r3
else
	SRC_URI="https://github.com/OpenImageDenoise/${PN}/releases/download/v${PV}/${P}.src.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
fi

IUSE="hip -hip-safe cuda sycl examples openimageio"
LICENSE="Apache-2.0"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE} hip? ( ${ROCM_REQUIRED_USE} ) hip-safe? ( hip )"

RDEPEND="${PYTHON_DEPS}
	examples? ( openimageio? ( media-libs/openimageio ) )
	sycl? (
		virtual/opencl
		dev-libs/intel-compute-runtime
	)
	hip? ( >=dev-util/hip-5.5.0 )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	dev-cpp/tbb:=
	dev-lang/ispc"
DEPEND="${RDEPEND}"
BDEPEND="
	hip? ( dev-util/hip )
"

PATCHES=(
	"${FILESDIR}/fix-hip.patch"
	"${FILESDIR}/amdgpu-targets.patch"
)

src_configure() {
	local mycmakeargs=(
		-DOIDN_DEVICE_CUDA=$(usex cuda)
		-DOIDN_DEVICE_HIP=$(usex hip)
		-DOIDN_DEVICE_SYCL=$(usex sycl)
		-DOIDN_APPS=$(usex examples)
	)

	if use examples; then
		mycmakeargs+=(
			-DOIDN_APPS_OPENIMAGEIO=$(usex openimageio)
		)
	fi

	if use hip; then
		mycmakeargs+=(
			-DOIDN_DEVICE_HIP_COMPILER="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang++"
			-DROCM_PATH="$(hipconfig -R)"
			-DOIDN_DEVICE_HIP_COMPILER="$(hipconfig -p)/bin/hipcc"
		)

		if ! use hip-safe; then
			mycmakeargs+=(
				-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
			)
			sed -e "s/CACHE INTERNAL/CACHE STRING/" -i devices/hip/CMakeLists.txt || die
		fi
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use hip || use cuda ; then
		rm -rf "${ED}"/var || die
	fi
}

pkg_postinst() {
	if use hip; then
		if ! use hip-safe; then
			ewarn ""
			ewarn "Please ensure that OIDN is built for all GPUs present on the system it is going to run on."
			ewarn "The HIP runtime has a bug that causes a crash if no kernel is valid for each GPU present."
			ewarn "Enable the USE flag 'hip-safe' to build all kernels if you observe crashes."
			ewarn ""
		fi
	fi 
}