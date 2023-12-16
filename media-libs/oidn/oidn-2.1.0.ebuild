# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )

inherit cmake python-single-r1

DESCRIPTION="Intel(R) Open Image Denoise library"
HOMEPAGE="https://www.openimagedenoise.org/"

if [[ ${PV} = *9999 ]]; then
	EGIT_REPO_URI="https://github.com/OpenImageDenoise/oidn.git"
	EGIT_BRANCH="master"
	inherit git-r3
else
	SRC_URI="https://github.com/OpenImageDenoise/${PN}/releases/download/v${PV}/${P}.src.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~arm64 ~ppc64 ~x86"
fi

IUSE="hip cuda opencl examples openimageio"
LICENSE="Apache-2.0"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	openimageio? ( media-libs/openimageio )
	opencl? ( virtual/opencl )
	hip? ( dev-util/hip )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	dev-cpp/tbb:=
	dev-lang/ispc"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DOIDN_DEVICE_CUDA=$(usex cuda)
		-DOIDN_DEVICE_HIP=$(usex hip)
		-DOIDN_DEVICE_SYCL=$(usex opencl)
		-DOIDN_APPS=$(usex examples)
		-DOIDN_APPS_OPENIMAGEIO=$(usex openimageio)
	)

	cmake_src_configure
}
