# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Patterns for app-forensics/imhex"
HOMEPAGE="https://imhex.werwolv.net/"
SLOT="0"
KEYWORDS="amd64 arm arm64"

inherit git-r3
EGIT_SUBMODULES=( -rules -patterns/ffx -patterns/bastion )
EGIT_REPO_URI="https://github.com/WerWolv/ImHex-Patterns.git"
YARA_REPO_URI="https://github.com/Yara-Rules/rules.git"
FFX_REPO_URI="https://gitlab.com/EvelynTSMG/imhex-ffx-pats.git"
BASTION_REPO_URI="https://gitlab.com/EvelynTSMG/imhex-bastion-pats.git"
S="${WORKDIR}/${P}"

LICENSE="|| ( GPL-2 )"

# RDEPEND="
# 	app-forensics/imhex
# "

src_unpack() {
	git-r3_src_unpack
	EGIT_SUBMODULES=( '*' )
	git-r3_fetch $YARA_REPO_URI
	git-r3_fetch $FFX_REPO_URI
	git-r3_fetch $BASTION_REPO_URI
	EGIT_CHECKOUT_DIR="${S}/yara/official_rules"
	git-r3_checkout $YARA_REPO_URI
	EGIT_CHECKOUT_DIR="${S}/patterns/ffx"
	git-r3_checkout $FFX_REPO_URI
	EGIT_CHECKOUT_DIR="${S}/patterns/bastion"
	git-r3_checkout $BASTION_REPO_URI
}

src_install() {
	insinto /usr/share/imhex
	rm -rf "${S}/tests"
	doins -r "${S}"/*
}
