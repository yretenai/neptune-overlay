# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson-multilib multilib

DESCRIPTION="SVG rendering and manipulation library in C++"
HOMEPAGE="https://github.com/sammycage/lunasvg"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/sammycage/lunasvg.git"
else
	SRC_URI="https://github.com/sammycage/lunasvg/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="static-libs"
RESTRICT="test"

multilib_src_install_all() {
	dodoc README.md
}
