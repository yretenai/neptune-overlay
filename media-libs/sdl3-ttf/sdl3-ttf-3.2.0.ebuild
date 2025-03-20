# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

MY_P="SDL3_ttf-${PV}"
DESCRIPTION="Library that allows you to use TrueType fonts in SDL applications"
HOMEPAGE="https://www.libsdl.org/projects/SDL_ttf/"
SRC_URI="https://github.com/libsdl-org/SDL_ttf/releases/download/release-${PV}/${MY_P}.tar.gz"
S="${WORKDIR}"/${MY_P}

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+harfbuzz +svg static-libs"
RESTRICT="test"

RDEPEND="
	>=media-libs/libsdl3-3.2.0[${MULTILIB_USEDEP}]
	media-libs/freetype[harfbuzz?,${MULTILIB_USEDEP}]
	harfbuzz? ( media-libs/harfbuzz:=[${MULTILIB_USEDEP}] )
	svg? ( media-libs/plutosvg:=[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-3.2.0-plutosvg-path.patch"
)

multilib_src_configure() {
	local mycmakeargs=(
		-DSDLTTF_VENDORED=OFF
		-DSDLTTF_HARFBUZZ=$(usex harfbuzz)
		-DSDLTTF_PLUTOSVG=$(usex svg)
	)

	cmake_src_configure
}

multilib_src_install_all() {
	dodoc CHANGES.txt README.md
}
