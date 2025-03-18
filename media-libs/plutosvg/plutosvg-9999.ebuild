# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson-multilib multilib

DESCRIPTION="Tiny SVG rendering library in C"
HOMEPAGE="https://github.com/sammycage/plutosvg"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/sammycage/plutosvg.git"
else
	SRC_URI="https://github.com/sammycage/plutosvg/archive/refs/tags/v${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+freetype static-libs"
RESTRICT="test"

RDEPEND="
	media-libs/plutovg[${MULTILIB_USEDEP}]
	freetype? ( media-libs/freetype[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}"

multilib_src_configure() {
	local emesonargs=(
		$(meson_feature freetype)
	)

	meson_src_configure
}

multilib_src_install_all() {
	dodoc README.md
}
