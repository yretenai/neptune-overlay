# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson git-r3

DESCRIPTION="a vulkan post processing layer for linux"
HOMEPAGE="https://github.com/DadSchoorse/vkBasalt"
EGIT_REPO_URI="https://github.com/DadSchoorse/${PN}.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="ZLIB"
SLOT="0"
IUSE="+reshade-shaders"
RESTRICT="test"

RDEPEND="
	reshade-shaders? ( media-gfx/reshade-shaders )
	x11-libs/libX11
"

BDEPEND="
	dev-util/spirv-headers
	dev-util/vulkan-headers
	dev-util/glslang
"

src_configure() {
	local emesonargs=()

	emesonargs+=(
		-Dwith_so=true
		-Dwith_json=true
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	if use reshade-shaders; then
		sed -i "s|/path/to/reshade-shaders/|${EPREFIX}/usr/share/reshade-shaders/|g" config/${PN}.conf || die
	fi
	insinto /usr/share/${PN}
	doins config/${PN}.conf
}
