# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION=" Fast and lightweight x86/x86-64 disassembler and code generation library"
HOMEPAGE="https://github.com/zyantific/zydis"
LICENSE="MIT"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zyantific/zydis.git"
else
	SRC_URI="
		https://github.com/zyantific/zydis/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	"
	KEYWORDS="~amd64"
fi

IUSE="man doc clang"

DEPEND="
	>=dev-libs/zycore-1.5.0[clang?]
"

RDEPEND="
	${DEPEND}
"

BDEPEND="
	man? ( app-text/ronn-ng )
	doc? ( app-text/doxygen )
	clang? ( llvm-core/clang )
"

PATCHES=(
	"${FILESDIR}/zydis-5.0.0a-patch-version.patch"
)

src_configure() {
	if use clang; then
		CC="${CHOST}-clang"
		CXX="${CHOST}-clang++"
		AR=llvm-ar
		append-ldflags "-fuse-ld=lld"
	fi

	local mycmakeargs=(
		-D ZYDIS_BUILD_SHARED_LIB=ON
		-D ZYDIS_BUILD_EXAMPLES=ON
		-D ZYDIS_BUILD_TOOLS=ON
		-D ZYDIS_BUILD_MAN=$(usex man)
		-D ZYDIS_BUILD_DOXYGEN=$(usex doc)
		-D ZYAN_SYSTEM_ZYCORE=ON
	)

	cmake_src_configure
}
