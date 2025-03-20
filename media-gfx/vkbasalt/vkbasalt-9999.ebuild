# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="a vulkan post processing layer for linux"
HOMEPAGE="https://github.com/DadSchoorse/vkBasalt"
LICENSE="ZLIB"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/DadSchoorse/vkBasalt.git"
else
	SRC_URI="https://github.com/DadSchoorse/vkBasalt/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/vkBasalt-${PV}"
	KEYWORDS="~amd64"
fi

RESTRICT="test"

RDEPEND="
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

	sed -i "s|/path/to/reshade-shaders/|${EPREFIX}/usr/share/reshade-shaders/|g" config/vkBasalt.conf || die
	insinto /usr/share/vkBasalt.conf
	doins config/vkBasalt.conf
}
