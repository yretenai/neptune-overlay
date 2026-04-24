# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Patterns for app-editors/imhex"
HOMEPAGE="https://imhex.werwolv.net/"

S="${WORKDIR}/${P}"
LICENSE="GPL-2"
SLOT="0"

inherit git-r3
EGIT_REPO_URI="https://github.com/WerWolv/ImHex-Patterns.git"

RDEPEND="
	app-editors/imhex
"

src_install() {
	insinto /usr/share/imhex
	cd "${S}"
	rm -rf ".github" "tests"
	dodoc CONTRIBUTING.md LICENSE README.md
	rm CONTRIBUTING.md LICENSE README.md .gitattributes .gitignore .gitmodules
	doins -r "${S}"/*
}
