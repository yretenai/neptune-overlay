# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_BUILD_TYPE="Release"
CMAKE_MAKEFILE_GENERATOR="emake"

inherit cmake toolchain-funcs git-r3

DESCRIPTION="The Pattern Language used by the ImHex Hex Editor"
HOMEPAGE="https://github.com/WerWolv/PatternLanguage"
LICENSE="LGPL-2.1"
SLOT="0"

EGIT_REPO_URI="https://github.com/WerWolv/PatternLanguage.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

DEPEND="
	>=dev-cpp/nlohmann_json-3.10.2
	>=dev-libs/libfmt-8.0.0:=
"
RDEPEND="${DEPEND}"
BDEPEND="
	sys-devel/lld
"

pkg_pretend() {
	if tc-is-gcc && [[ $(gcc-major-version) -lt 12 ]]; then
		die "${PN} requires GCC 12 or newer"
	fi
}

src_prepare() {
	sed -e "s| -Werror||g" -i lib/CMakeLists.txt || die
	sed -e "s| DESTINATION lib||g" -i lib/CMakeLists.txt || die
	sed -e "s| -Werror||g" -i cli/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D CMAKE_BUILD_TYPE="Release" \
		-D CMAKE_C_COMPILER_LAUNCHER=ccache \
		-D CMAKE_CXX_COMPILER_LAUNCHER=ccache \
		-D CMAKE_C_FLAGS="-fuse-ld=lld ${CFLAGS}" \
		-D CMAKE_CXX_FLAGS="-fuse-ld=lld ${CXXFLAGS}" \
		-D CMAKE_OBJC_COMPILER_LAUNCHER=ccache \
		-D CMAKE_OBJCXX_COMPILER_LAUNCHER=ccache \
		-D CMAKE_SKIP_RPATH=ON \
		-D LIBPL_SHARED_LIBRARY=ON \
		-D LIBPL_ENABLE_TESTS=OFF \
		-D LIBPL_ENABLE_CLI=ON \
		-D LIBPL_BUILD_CLI_AS_EXECUTABLE=ON \
		-D LIBPL_ENABLE_EXAMPLE=OFF \
		-D PROJECT_VERSION="${PV}" \
		-D USE_SYSTEM_FMT=ON \
		-D USE_SYSTEM_NLOHMANN_JSON=ON \
	)

	cmake_src_configure
}

src_install() {
	default
	cmake_src_install
	doheader -r lib/include/pl
	doheader lib/include/pl.hpp
}
