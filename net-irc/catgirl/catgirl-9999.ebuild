# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit edo git-r3 readme.gentoo-r1 toolchain-funcs

DESCRIPTION="TLS-only terminal IRC client"
HOMEPAGE="https://git.causal.agency/catgirl/about/"
LICENSE="GPL-3+"
SLOT="0"

EGIT_REPO_URI="https://git.causal.agency/catgirl"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-libs/libretls:=
	sys-libs/ncurses:=
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

DOCS=( README.7 scripts/chat.tmux.conf )

src_configure() {
	tc-export CC

	# note: not an autoconf configure script
	edo ./configure --prefix="${EPREFIX}"/usr --mandir="${EPREFIX}"/usr/share/man
}

src_compile() {
	emake all
}

src_install() {
	default
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
