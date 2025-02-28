# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Patterns for app-editors/imhex"
HOMEPAGE="https://imhex.werwolv.net/"

S="${WORKDIR}/${P}"
LICENSE="GPL-2"
SLOT="0"

inherit git-r3 vcs-clean
EGIT_REPO_URI="https://github.com/WerWolv/ImHex-Patterns.git"
if [[ "${PV}" != *99999999* ]]; then
	EGIT_COMMIT="1d66949375e8ca05dcb4d96121468aac4ebec3c4"
	KEYWORDS="~amd64"
fi

RDEPEND="
	app-editors/imhex
"

src_prepare() {
	default
	egit_clean
}

src_install() {
	insinto /usr/share/imhex
	rm -rf "${S}/tests"
	doins -r "${S}"/*
}
