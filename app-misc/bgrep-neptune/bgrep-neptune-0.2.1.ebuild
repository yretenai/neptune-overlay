# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Grep-like tool to search for binary strings"
HOMEPAGE="https://github.com/neptuwunium/bgrep/"
SRC_URI="https://github.com/neptuwunium/bgrep/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/bgrep-${PV}"

LICENSE="BSD"
SLOT="0"

KEYWORDS="~amd64 ~arm64"

IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="test? ( dev-lang/perl )"

RDEPEND="
	!app-misc/bgrep
"

BDEPEND="
	!app-misc/bgrep
"

src_prepare() {
	default
	sed -i -e "s|/tmp/|${T}/|g" \
		test/bgrep-test.sh || die
}

src_compile() {
	tc-export CC
	emake
}

src_test() {
	cd test || die
	./bgrep-test.sh || die
}

src_install() {
	dobin bgrep
	dodoc README
}
