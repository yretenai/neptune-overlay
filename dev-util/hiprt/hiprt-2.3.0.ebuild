# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="5.7.1"

inherit rocm git-r3 flag-o-matic toolchain-funcs

DESCRIPTION="HIP RT is a ray tracing library for HIP, making it easy to write ray-tracing applications in HIP. The APIs and library are designed to be minimal, lower level, and simple to use and integrate into any existing HIP applications."
HOMEPAGE="https://gpuopen.com/hiprt/
https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT
"
EGIT_REPO_URI="https://github.com/GPUOpen-LibrariesAndSDKs/HIPRT.git"
EGIT_COMMIT="5ffcea6322519b25500f6d3140bbb42dd06fb464"

KEYWORDS="~amd64"
LICENSE="MIT"
SLOT="0"

RDEPEND="
    dev-util/hip
	>=media-libs/embree-4
"
DEPEND="${RDEPEND}"

BDEPEND="
    dev-util/premake:5
"

PATCHES=(
	"${FILESDIR}/${PN}-system-embree.patch"
	"${FILESDIR}/${PN}-precompile.patch"
)

src_prepare() {
    default

    sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i contrib/Orochi/scripts/kernelCompile.py || die
    sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i scripts/bitcodes/compile.py || die
    sed -e "s|__AMDGPU_FLAGS__|$(get_amdgpu_flags)|" -i scripts/bitcodes/precompile_bitcode.py || die
}

src_configure() {
    premake5 gmake --precompile --bitcode
}

src_compile() {
    make -C build -j config=release_x64
}

src_install() {
    dolib.so dist/bin/Release/libhiprt0200364.so
	doheader -r hiprt
	into /opt/hiprt
    newbin scripts/bitcodes/hiprt02003_5.7_amd.hipfb hiprt02003_amd.hipfb
    newbin scripts/bitcodes/hiprt02003_5.7_amd_lib_linux.bc hiprt02003_amd_lib_linux.bc
    dobin contrib/Orochi/bitcodes/oro_compiled_kernels.hipfb
}
