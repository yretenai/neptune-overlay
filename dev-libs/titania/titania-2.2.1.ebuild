# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson git-r3

DESCRIPTION="a vulkan post processing layer for linux"
HOMEPAGE="https://git.sr.ht/~chronovore/titania"
EGIT_REPO_URI="https://git.sr.ht/~chronovore/titania"

EGIT_VLHL_JSON_COMMIT="c0bcb33d99ff939eb75758f80c948a10ea6733d2"
EGIT_VLHL_JSON_REPO="https://git.vlhl.dev/navi/json.git"
EGIT_VLHL_JSON_LOCAL_ID="${CATEGORY}/${PN}/${SLOT%/*}-json"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="MPL-2.0 GPL-3"
SLOT="0"
IUSE="+doc +cli debug"
RESTRICT="test"

RDEPEND="
	>=dev-libs/hidapi-0.13.0
"

BDEPEND="
	${RDEPEND}
	>=dev-build/meson-1.3.0
	doc? (
		virtual/pandoc
	)
"

src_unpack() {
	git-r3_fetch "${EGIT_VLHL_JSON_REPO}" "${EGIT_VLHL_JSON_COMMIT}" "${EGIT_VLHL_JSON_LOCAL_ID}"
	git-r3_checkout "${EGIT_VLHL_JSON_REPO}" "${S}/subprojects/libjson" "${EGIT_VLHL_JSON_LOCAL_ID}"
	git-r3_src_unpack
}

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
