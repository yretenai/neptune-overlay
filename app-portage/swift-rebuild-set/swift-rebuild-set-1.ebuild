# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Swift Rebuild Set"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm ~arm64"
RESTRICT="test"

src_unpack() {
	mkdir "${S}"
}

src_install() {
	insinto /usr/share/portage/config/sets
	newins "${FILESDIR}"/${PN}.conf swift-rebuild.conf
}
