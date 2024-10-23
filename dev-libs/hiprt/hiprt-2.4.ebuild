# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
LLVM_COMPAT=( 18 )
ROCM_VERSION="6.1.2"
CMAKE_BUILD_TYPE="Release"

inherit rocm cmake git-r3 python-single-r1 llvm-r1 python-utils-r1

DESCRIPTION="HIP RT is a ray tracing library for HIP."
HOMEPAGE="
	https://gpuopen.com/hiprt/
	https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT
"

EGIT_LFS=no # fetches test data
EGIT_REPO_URI="https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT.git"
EGIT_COMMIT="3a8b83609bc347270643db12b422a6315cb89f81"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

RDEPEND="
	${PYTHON_DEPS}
	$(llvm_gen_dep "
		>=dev-util/hip-${ROCM_VERSION}:=[llvm_slot_\${LLVM_SLOT}]
	")
"
DEPEND="${RDEPEND}"

BDEPEND="
	dev-util/premake:5
"

PATCHES=(
	"${FILESDIR}/${PN}-${PV}-precompile.patch"
	"${FILESDIR}/${PN}-no-nvidia.patch"
	"${FILESDIR}/${PN}-output.patch"
)

RESTRICT="test"

pkg_setup() {
	python-single-r1_pkg_setup
	llvm-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare
	
	_python_check_EPYTHON
	sed -e "s| python | ${EPYTHON} |" -i CMakeLists.txt || die
	sed -e "s|hiprt\${version_str_}|hiprt|" -i CMakeLists.txt || die
	sed -e "s|\${HIPRT_NAME} SHARED)|\${HIPRT_NAME} SHARED)\nset_target_properties(\${HIPRT_NAME} PROPERTIES VERSION ${PV} SOVERSION 1)|" -i CMakeLists.txt || die

	sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i contrib/Orochi/scripts/kernelCompile.py || die
	sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i scripts/bitcodes/compile.py || die
	sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i scripts/bitcodes/precompile_bitcode.py || die

	chmod +x contrib/easy-encryption/bin/linux/ee64 || die
}

src_configure() {
	local mycmakeargs=(
		-DBITCODE=ON
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
