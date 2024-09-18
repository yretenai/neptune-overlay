# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Electron Virtual"
HOMEPAGE="
	https://www.electronjs.org/
	https://github.com/electron/electron
"

KEYWORDS="~amd64"
LICENSE="MIT"
SLOT="0"
RESTRICT="test"

src_unpack() {
	mkdir "${S}"
}

src_install() {
	insinto /usr/share/portage/config/sets
	newins "${FILESDIR}"/electron-sets.conf electron.conf
}
