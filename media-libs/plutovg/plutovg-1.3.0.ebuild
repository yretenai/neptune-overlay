# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson-multilib

DESCRIPTION="Tiny 2D vector graphics library in C"
HOMEPAGE="https://github.com/sammycage/plutovg"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/sammycage/plutovg.git"
else
	SRC_URI="https://github.com/sammycage/plutovg/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="MIT"
SLOT="0"
IUSE="static-libs"
RESTRICT="test"

multilib_src_install_all() {
	dodoc README.md
}
