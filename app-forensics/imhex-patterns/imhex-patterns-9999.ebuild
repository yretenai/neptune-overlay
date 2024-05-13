# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Patterns for app-forensics/imhex"
HOMEPAGE="https://imhex.werwolv.net/"

S="${WORKDIR}/${P}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm arm64"

inherit git-r3 vcs-clean
EGIT_REPO_URI="https://github.com/WerWolv/ImHex-Patterns.git"

RDEPEND="
	app-forensics/imhex
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
