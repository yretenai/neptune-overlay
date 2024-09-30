# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION=" Fast and lightweight x86/x86-64 disassembler and code generation library"
HOMEPAGE="https://github.com/zyantific/zydis"

EGIT_REPO_URI="https://github.com/zyantific/zydis.git"
EGIT_SUBMODULES=( )

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~ppc64 ~x86"
fi

IUSE="man doc"

LICENSE="MIT"
SLOT="0"

DEPEND="
	>=dev-libs/zycore-1.5.0
"

RDEPEND="
	${DEPEND}
"

BDEPEND="
	man? (
		app-text/ronn-ng
	)
	doc? (
		app-text/doxygen
	)
	sys-devel/clang
"

PATCHES=(
	"${FILESDIR}/patch-version-${PV}.patch"
)

src_configure() {
	CC="${CHOST}-clang"
	CXX="${CHOST}-clang++"
	AR=llvm-ar
	LDFLAGS="-fuse-ld=lld ${LDFLAGS}"

	local mycmakeargs=(
		-D ZYDIS_BUILD_SHARED_LIB=ON
		-D ZYDIS_BUILD_EXAMPLES=ON
		-D ZYDIS_BUILD_TOOLS=ON
		-D ZYDIS_BUILD_MAN=$(usex man)
		-D ZYDIS_BUILD_DOXYGEN=$(usex doc)
		-D SIRIT_USE_SYSTEM_SPIRV_HEADERS=ON
		-D ZYAN_SYSTEM_ZYCORE=ON
	)

	cmake_src_configure
}
