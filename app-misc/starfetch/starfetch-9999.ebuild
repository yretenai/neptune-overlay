# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

if [[ ${PV} != *9999* ]]; then
	SRC_URI="https://github.com/Haruno19/starfetch/archive/${PV}/${P}.tar.gz"
	KEYWORDS="~amd64"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Haruno19/starfetch.git"
fi

DESCRIPTION="command line tool that displays constellations"
HOMEPAGE="https://github.com/Haruno19/starfetch/"
LICENSE="GPL-3"
SLOT="0"

src_prepare() {
	default

	sed -e "s|/usr/local/share/starfetch|${EPREFIX}/usr/share/${PN}|" -i src/starfetch.cpp || die
}

src_install() {
	dobin starfetch
	insinto "${EPREFIX}"/usr/share/${PN}; doins -r res/*
}
