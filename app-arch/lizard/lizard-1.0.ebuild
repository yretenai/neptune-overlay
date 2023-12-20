# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="An efficient compressor with very fast decompression, formerly known as LZ5"
HOMEPAGE="https://github.com/inikep/lizard"
SRC_URI="https://github.com/inikep/lizard/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2 BSD-2"
SLOT="0/2"
KEYWORDS="~amd64"

PATCHES=(
	"${FILESDIR}/libdir-fix.patch"
)

src_prepare() {
	default
	sed -i -e 's/install: lizard$(EXT)/install:/' programs/Makefile || die
	sed -i -e 's/install: lib liblizard.pc/install:/' lib/Makefile || die
}

src_compile() {
	emake -C lib CC="$(tc-getCC)" lib liblizard.pc
	emake -C programs CC="$(tc-getCC)" lizard
}

src_install() {
	emake install DESTDIR="${ED}" PREFIX="/usr" LIBDIR="/usr/$(get_libdir)"
	rm "${ED}"/usr/$(get_libdir)/liblizard.a || die

	einstalldocs
}
