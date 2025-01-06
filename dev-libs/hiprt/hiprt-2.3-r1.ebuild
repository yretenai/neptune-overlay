# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} python3_13t )
LLVM_COMPAT=( 18 19 )
CMAKE_BUILD_TYPE="Release"
EGIT_LFS="no" # fetches test data
ROCM_VERSION="6.3"

inherit rocm cmake git-r3 python-single-r1 llvm-r1

DESCRIPTION="HIP RT is a ray tracing library for HIP."
HOMEPAGE="
	https://gpuopen.com/hiprt/
	https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT
"

EGIT_REPO_URI="https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT.git"
EGIT_COMMIT="83e18cc9c3de8f2f9c48b663cf3189361e891054"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

RDEPEND="
	${PYTHON_DEPS}
	llvm_slot_18? (
		>=dev-util/hip-6.1:=[llvm_slot_18(-)]
	)
	llvm_slot_19? (
		>=dev-util/hip-6.3:=[llvm_slot_19(-)]
	)
"
DEPEND="${RDEPEND}"

BDEPEND="
	dev-util/premake:5
"

PATCHES=(
	"${FILESDIR}/${PN}-output.patch"
	"${FILESDIR}/${PN}-${PV}-precompile.patch"
)

RESTRICT="test"

pkg_setup() {
	python-single-r1_pkg_setup
	llvm-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	if ! use cuda; then
		eapply "${FILESDIR}/${PN}-${PV}-no-nvidia.patch"
	fi

	sed -e "s|set(HIPRT_NAME \"hiprt\${version_str_}\")|set(HIPRT_NAME \"hiprt\")|" -i CMakeLists.txt || die
	sed -e "s| python | ${EPYTHON} |" -i CMakeLists.txt || die
	sed -e "s|\${HIPRT_NAME} SHARED)|\${HIPRT_NAME} SHARED)\nset_target_properties(\${HIPRT_NAME} PROPERTIES VERSION ${PV} SOVERSION 1)|" -i CMakeLists.txt || die

	sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i contrib/Orochi/scripts/kernelCompile.py || die
	sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i scripts/bitcodes/compile.py || die
	sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i scripts/bitcodes/precompile_bitcode.py || die

	chmod +x contrib/easy-encryption/bin/linux/ee64 || die
}

src_configure() {
	local mycmakeargs=(
		-DBITCODE=ON
		-DBAKE_KERNEL=OFF # cannot coexist with BITCODE
		-DPRECOMPILE=ON
		-DNO_UNITTEST=ON
		-DHIPRT_PREFER_HIP_5=OFF
		-DHIP_PATH="${EPREFIX}/usr"
		-DCMAKE_BUILD_TYPE="Release"
		-DCMAKE_INSTALL_DATADIR="${EPREFIX}/usr/share"
	)

	cmake_src_configure
}

src_compile() {
	export PYTHON_BIN="${EPYTHON}"
	cmake_src_compile
}
