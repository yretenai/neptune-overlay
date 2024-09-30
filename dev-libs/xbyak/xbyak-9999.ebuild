# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="JIT assembler for x86(IA-32)/x64(AMD64, x86-64)"
HOMEPAGE="https://github.com/herumi/xbyak"

EGIT_REPO_URI="https://github.com/herumi/xbyak.git"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~ppc64 ~x86"
fi

LICENSE="BSD"
SLOT="0"

BDEPEND="
	sys-devel/clang
"

src_configure() {
	CC="${CHOST}-clang"
	CXX="${CHOST}-clang++"
	AR=llvm-ar
	LDFLAGS="-fuse-ld=lld ${LDFLAGS}"

	cmake_src_configure
}
