# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
LLVM_COMPAT=( 18 )
ROCM_VERSION="6.1.1"
CMAKE_BUILD_TYPE="Release"

inherit rocm cmake git-r3 python-single-r1 llvm-r1 python-utils-r1

DESCRIPTION="HIP RT is a ray tracing library for HIP."
HOMEPAGE="
	https://gpuopen.com/hiprt/
	https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT
"

EGIT_LFS=no # fetches test data
EGIT_REPO_URI="https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT.git"
EGIT_COMMIT="83e18cc9c3de8f2f9c48b663cf3189361e891054"

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
	"${FILESDIR}/${PN}-bcinstall.patch"
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
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/$(get_libdir)/hiprt"
	)

	cmake_src_configure
}

src_compile() {
	export PYTHON_BIN="${EPYTHON}"
	cmake_src_compile
}

src_install() {
	cmake_src_install
	dosym "hiprt/bin/libhiprt0200364.so" "${EPREFIX}/usr/$(get_libdir)/libhiprt64.so"
	dosym "hiprt/bin/hiprt02003_6.1_amd.hipfb" "${EPREFIX}/usr/$(get_libdir)/hiprt02003_6.1_amd.hipfb"
	dosym "hiprt/bin/hiprt02003_6.1_amd_lib_linux.bc" "${EPREFIX}/usr/$(get_libdir)/hiprt02003_6.1_amd_lib_linux.bc"
	dosym "hiprt/bin/oro_compiled_kernels.hipfb" "${EPREFIX}/usr/$(get_libdir)/oro_compiled_kernels.hipfb"
}
