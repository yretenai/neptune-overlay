# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO(???): Check CUDA, I (Ada) do not have a CUDA-capable GPU to test this on.
# TODO(ada): Fix AMDGPU_TARGETS being hardcoded -> https://github.com/OpenImageDenoise/oidn/blob/v2.1.0/devices/hip/CMakeLists.txt#L24-L29
# TODO(ada): Only use openimageio if examples is also set.

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

ROCM_VERSION="5.7.1"

inherit rocm cuda cmake python-single-r1

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

IUSE="hip cuda sycl examples openimageio"
LICENSE="Apache-2.0"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE} hip? ( ${ROCM_REQUIRED_USE} )"

RDEPEND="${PYTHON_DEPS}
	openimageio? ( media-libs/openimageio )
	sycl? (
		virtual/opencl
		dev-libs/intel-compute-runtime
	)
	hip? ( dev-util/hip )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	dev-cpp/tbb:=
	dev-lang/ispc"
DEPEND="${RDEPEND}"
BDEPEND="
	hip? ( dev-util/hip )
"

src_configure() {
	local mycmakeargs=(
		-DOIDN_DEVICE_CUDA=$(usex cuda)
		-DOIDN_DEVICE_HIP=$(usex hip)
		-DOIDN_DEVICE_SYCL=$(usex sycl)
		-DOIDN_APPS=$(usex examples)
		-DOIDN_APPS_OPENIMAGEIO=$(usex openimageio)
	)

	if use hip; then
		mycmakeargs+=(
			-DOIDN_DEVICE_HIP_COMPILER="$(hipconfig -p)/bin/hipcc"
			-DGPU_TARGETS="$(get_amdgpu_flags)"
			-DAMDGPU_TARGETS="$(get_amdgpu_flags)" # unsure if these are used, they're SET() not OPTION()
		)

		addpredict /dev/kfd
		addpredict /dev/dri
		export ROCM_PATH="$(hipconfig -R)"
	fi

	cmake_src_configure
}
