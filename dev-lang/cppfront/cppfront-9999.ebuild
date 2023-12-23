# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="An experimental C++ Syntax 2 -> Syntax 1 compiler"
HOMEPAGE="https://github.com/hsutter/cppfront"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hsutter/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/hsutter/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="CC-BY-NC-ND-4.0"
SLOT="0"

src_compile() {
	CXX=$(tc-getCXX)
	${CXX} ${CXXFLAGS} ${LDFLAGS} source/cppfront.cpp -std=c++20 -o cppfront
}

src_install() {
	insinto usr
	doins -r include
	dobin cppfront
}
