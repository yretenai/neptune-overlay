# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson git-r3

DESCRIPTION="a vulkan post processing layer for linux"
HOMEPAGE="https://git.sr.ht/~chronovore/titania"
LICENSE="MPL-2.0 GPL-3"
SLOT="0"

EGIT_REPO_URI="https://git.sr.ht/~chronovore/titania"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
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
