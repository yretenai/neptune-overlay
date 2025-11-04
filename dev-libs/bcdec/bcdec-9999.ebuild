# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="small header-only C library to decompress BC codecs"
HOMEPAGE="https://github.com/neptuwunium/bcdec"
LICENSE="Unlicense MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/neptuwunium/bcdec"
else
	SRC_URI="https://github.com/neptuwunium/bcdec/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	S="${WORKDIR}/${PN}-${PV}"
	KEYWORDS="~amd64 ~arm64"
fi
IUSE="+precise-bc3 +precise-bc4bc5"
RESTRICT="test"

BDEPEND="
	${RDEPEND}
	>=dev-build/meson-1.3.0
"

src_configure() {
	local emesonargs=(
		$(meson_use precise-bc4bc5 precise_bc4bc5)
		$(meson_use precise-bc3 precise_bc3)
	)

	meson_src_configure
}
