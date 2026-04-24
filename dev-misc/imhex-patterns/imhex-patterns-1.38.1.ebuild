# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Patterns for app-editors/imhex"
HOMEPAGE="https://imhex.werwolv.net/"

YARA_COMMIT="0f93570194a80d2f2032869055808b0ddcdfb360"
FFX_COMMIT="199879e24ac56fda9b6cb7e86a64d30f1290891e"
BASTION_COMMIT="e6deed433c4ba3e05e00e12fbef78c5d84e0ca18"

SRC_URI="
	https://github.com/WerWolv/ImHex-Patterns/archive/refs/tags/ImHex-v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/Yara-Rules/rules/archive/${YARA_COMMIT}.tar.gz -> ${PN}-yara-${YARA_COMMIT}.tar.gz
	https://gitlab.com/EvelynTSMG/imhex-ffx-pats/-/archive/${FFX_COMMIT}/imhex-ffx-pats-${FFX_COMMIT}.tar.bz2 -> ${PN}-ffx-${FFX_COMMIT}.tar.bz2
	https://gitlab.com/EvelynTSMG/imhex-bastion-pats/-/archive/${BASTION_COMMIT}/imhex-bastion-pats-${BASTION_COMMIT}.tar.bz2 -> ${PN}-bastion-${BASTION_COMMIT}.tar.bz2
"
S="${WORKDIR}/ImHex-Patterns-ImHex-v${PV}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-editors/imhex
"

src_prepare() {
	eapply_user
	rmdir patterns/bastion patterns/ffx yara/official_rules
	mv "${WORKDIR}/rules-${YARA_COMMIT}" yara/official_rules || die "cannot move yara rules"
	mv "${WORKDIR}/imhex-ffx-pats-${FFX_COMMIT}" patterns/ffx || die "cannot move ffx patterns"
	mv "${WORKDIR}/imhex-bastion-pats-${BASTION_COMMIT}" patterns/bastion || die "cannot move bastion patterns"
}

src_install() {
	insinto /usr/share/imhex
	cd "${S}"
	rm -rf ".github" "tests"
	dodoc CONTRIBUTING.md LICENSE README.md
	rm CONTRIBUTING.md LICENSE README.md .gitattributes .gitignore .gitmodules
	doins -r "${S}"/*
}
