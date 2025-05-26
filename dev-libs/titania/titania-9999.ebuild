# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Unofficial userland library for the Sony PlayStation DualSense Controller"
HOMEPAGE="https://git.sr.ht/~chronovore/titania"
LICENSE="MPL-2.0 GPL-3"
SLOT="0"

EGIT_REPO_URI="https://git.sr.ht/~chronovore/titania"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.sr.ht/~chronovore/titania"
else
	SRC_URI="https://git.sr.ht/~chronovore/titania/archive/v${PV}.tar.gz -> ${PN}-v${PV}.tar.gz"
	S="${WORKDIR}/${PN}-v${PV}"
	KEYWORDS="~amd64 ~arm64"
fi
IUSE="+doc +cli debug"
RESTRICT="test"

RDEPEND="
	>=dev-libs/hidapi-0.13.0
	cli? (
		>=dev-libs/libjson-navi-0.0.10
	)
"

BDEPEND="
	${RDEPEND}
	>=dev-build/meson-1.3.0
	doc? (
		virtual/pandoc
	)
"

src_configure() {
	local emesonargs=()

	emesonargs+=(
		$(meson_use cli titania_ctl)
		$(meson_use doc titania_man)
	)

	if use debug; then
		EMESON_BUILDTYPE="debug"
	else
		EMESON_BUILDTYPE="release"
	fi

	meson_src_configure
}
