# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
LLVM_COMPAT=( {15..18} )
ROCM_VERSION=5.7
EGIT_LFS="1"

inherit cmake cuda llvm-r1 python-any-r1 rocm git-r3

DESCRIPTION="Intel® Open Image Denoise library"
HOMEPAGE="https://www.openimagedenoise.org https://github.com/RenderKit/oidn"

EGIT_REPO_URI="https://github.com/RenderKit/oidn.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
fi

LICENSE="Apache-2.0"
SLOT="0"
REQUIRED_USE="
	test? ( apps )
"
IUSE="apps cuda hip hip-safe openimageio test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-cpp/tbb:=
	dev-lang/ispc
	cuda? ( dev-util/nvidia-cuda-toolkit )
	hip? ( dev-util/hip )
	openimageio? ( media-libs/openimageio:= )
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

PATCHES=(
	"${FILESDIR}/${PN}-2.2.2-amdgpu-targets.patch"
)

src_prepare() {
	if use cuda; then
		cuda_src_prepare
		addpredict "/proc/self/task/"
	fi

	if use hip; then
		# https://bugs.gentoo.org/930391
		sed "/-Wno-unused-result/s:): --rocm-path=${EPREFIX}/usr/lib):" \
			-i devices/hip/CMakeLists.txt || die
	fi

	sed -e "/^install.*llvm_macros.cmake.*cmake/d" -i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DOIDN_APPS="$(usex apps)"

		-DOIDN_DEVICE_CPU="yes"
		-DOIDN_DEVICE_CUDA="$(usex cuda)"
		-DOIDN_DEVICE_HIP="$(usex hip)"
		# -DOIDN_DEVICE_SYCL="$(usex sycl)"
	)

	if use apps; then
		mycmakeargs+=( -DOIDN_APPS_OPENIMAGEIO="$(usex openimageio)" )
	fi

	if use cuda; then
		export CUDAHOSTCXX="$(cuda_gccdir)"
	fi

	if use hip; then
		mycmakeargs+=(
			-DROCM_PATH="${EPREFIX}/usr"
			-DOIDN_DEVICE_HIP_COMPILER="$(get_llvm_prefix)/bin/clang++" # use HIPHOSTCOMPILER
		)

	   if ! use hip-safe; then
		   mycmakeargs+=(
			   -DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		   )
	   fi
	fi

	cmake_src_configure
}

src_test() {
	"${BUILD_DIR}"/oidnTest || die "There were test faliures!"
}

src_install() {
	cmake_src_install

	if use hip || use cuda ; then
		# remove garbage in /var/tmp left by subprojects
		rm -rf "${ED}"/var || die
	fi
}
