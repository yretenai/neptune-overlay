# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Internal library providing platform independent types, macros and a fallback for environments without LibC."
HOMEPAGE="https://github.com/zyantific/zycore-c"

EGIT_REPO_URI="https://github.com/zyantific/zycore-c.git"
EGIT_SUBMODULES=( )

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~ppc64 ~x86"
fi

LICENSE="MIT"
SLOT="0"

BDEPEND="
	sys-devel/clang
"

src_configure() {
	CC="${CHOST}-clang"
	CXX="${CHOST}-clang++"
	AR=llvm-ar
	LDFLAGS="-fuse-ld=lld ${LDFLAGS}"

	local mycmakeargs=(
		-D ZYCORE_BUILD_SHARED_LIB=ON
		-D ZYCORE_BUILD_EXAMPLES=ON
	)

	cmake_src_configure
}
