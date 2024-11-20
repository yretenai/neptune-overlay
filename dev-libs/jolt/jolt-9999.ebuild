# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION=" A multi core friendly rigid body physics and collision detection library. Written in C++"
HOMEPAGE="https://github.com/jrouwe/JoltPhysics"
LICENSE="MIT"
SLOT="0"

if [[ ${PV} != *9999* ]]; then
	SRC_URI="
		https://github.com/jrouwe/JoltPhysics/archive/refs/tags/v5.2.0.tar.gz -> jolt-${PV}.tar.gz
	"
	S="${WORKDIR}/JoltPhysics-${PV}"
	KEYWORDS="~amd64"
else
	inherit git-r3 
	EGIT_REPO_URI="https://github.com/jrouwe/JoltPhysics.git"
fi

CMAKE_USE_DIR="${S}/Build"

CPU_FLAGS_X86=(sse4_1 sse4_2 f16c popcnt fma3 avx avx2 avx512f avx512vl)
IUSE="
	test debug clang lto
	profiler +renderer +custom-allocator deterministic +double-precision std rtti
	${CPU_FLAGS_X86[@]/#/cpu_flags_x86_}
"

BDEPEND="
	clang? ( sys-devel/clang )
"

RESTRICT="!test? ( test )"

src_configure() {
	if use clang; then
		CC="${CHOST}-clang"
		CXX="${CHOST}-clang++"
		AR=llvm-ar
		append-ldflags "-fuse-ld=lld"
	fi

	local mycmakeargs=(
		-D BUILD_SHARED_LIBS=ON
		-D CPP_EXCEPTIONS_ENABLED=$(usex debug)
		-D CPP_RTTI_ENABLED=$(usex rtti)
		-D CROSS_PLATFORM_DETERMINISTIC=$(usex deterministic)
		-D DEBUG_RENDERER_IN_DEBUG_AND_RELEASE=$(usex renderer)
		-D DEBUG_RENDERER_IN_DISTRIBUTION=$(usex renderer)
		-D DISABLE_CUSTOM_ALLOCATOR=$(usex custom-allocator ON OFF)
		-D DOUBLE_PRECISION=$(usex double-precision)
		-D INTERPROCEDURAL_OPTIMIZATION=$(usex lto)
		-D PROFILER_IN_DEBUG_AND_RELEASE=$(usex profiler)
		-D PROFILER_IN_DISTRIBUTION=$(usex profiler)
		-D USE_ASSERTS=$(usex debug)
		-D USE_STD_VECTOR=$(usex std)
		-D USE_SSE4_1=$(usex cpu_flags_x86_sse4_1)
		-D USE_SSE4_2=$(usex cpu_flags_x86_sse4_2)
		-D USE_F16C=$(usex cpu_flags_x86_f16c)
		-D USE_LZCNT=$(usex cpu_flags_x86_popcnt)
		-D USE_TZCNT=$(usex cpu_flags_x86_popcnt)
		-D USE_AVX=$(usex cpu_flags_x86_avx)
		-D USE_AVX2=$(usex cpu_flags_x86_avx2)
		-D USE_AVX512=$(usex cpu_flags_x86_avx512f $(usex cpu_flags_x86_avx512vl) OFF)
		-D USE_FMADD=$(usex cpu_flags_x86_fma3)
	)

	cmake_src_configure
}

src_test() {
	cd "${BUILD_DIR}"
	./UnitTests || die "tests failed"
}
