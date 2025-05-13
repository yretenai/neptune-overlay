# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} python3_{13..14}t )
LLVM_COMPAT=( {18..20} )
CMAKE_BUILD_TYPE="Release"
EGIT_LFS="no" # fetches test data
ROCM_VERSION="6.3"

inherit neptune-rocm cmake python-single-r1 llvm-r1

DESCRIPTION="HIP RT is a ray tracing library for HIP."
HOMEPAGE="
	https://gpuopen.com/hiprt/
	https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT
"

COMMIT="c4298933fe046e3f915977b5a69537a59aac8f47"
SRC_URI="https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/HIPRT-${COMMIT}"

LICENSE="MIT"
SLOT="$(ver_cut 0-2)"
KEYWORDS="~amd64"
IUSE="cuda"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

RDEPEND="
	${PYTHON_DEPS}
	dev-util/hip:=
"
DEPEND="${RDEPEND}"

BDEPEND="
	dev-util/premake:5
"

PATCHES=(
	"${FILESDIR}/${PN}-2.5.4-precompile.patch"
	"${FILESDIR}/${PN}-2.3-datadir.patch"
	"${FILESDIR}/${PN}-2.3-output.patch"
	"${FILESDIR}/${PN}-2.3-output2.patch"
)

RESTRICT="test"

pkg_setup() {
	python-single-r1_pkg_setup
	llvm-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	sed -e "s|set(HIPRT_NAME \"hiprt\${version_str_}\")|set(HIPRT_NAME \"hiprt\")|" -i CMakeLists.txt || die
	sed -e "s|\${HIPRT_NAME} SHARED)|\${HIPRT_NAME} SHARED)\nset_target_properties(\${HIPRT_NAME} PROPERTIES VERSION ${PV} SOVERSION 1)|" -i CMakeLists.txt || die

	sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i contrib/Orochi/scripts/kernelCompile.py || die
	sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i scripts/bitcodes/compile.py || die
	sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i scripts/bitcodes/precompile_bitcode.py || die

	chmod +x contrib/easy-encryption/bin/linux/ee64 || die

	sed -E "s|SOVERSION 1|SOVERSION ${SLOT}|" -i CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DBITCODE=ON
		-DBAKE_COMPILED_KERNEL=ON
		-DBAKE_KERNEL=ON
		-DPRECOMPILE=ON
		-DNO_UNITTEST=ON
		-DHIPRT_PREFER_HIP_5=OFF
		-DHIP_PATH="${EPREFIX}/usr"
		-DPYTHON_EXECUTABLE="${PYTHON}"
		-DFORCE_DISABLE_CUDA=$(usex !cuda)
		-DCMAKE_INSTALL_DATADIR="${EPREFIX}/usr/share"
	)

	cmake_src_configure
}

src_compile() {
	export PYTHON_BIN="${EPYTHON}"
	cmake_src_compile
}

src_install() {
	cmake_src_install
	rm "${ED}"/usr/$(get_libdir)/libhiprt64.so || die
}
