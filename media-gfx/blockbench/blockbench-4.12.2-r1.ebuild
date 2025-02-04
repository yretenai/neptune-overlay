# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="${LATEST_ELECTRON_VER}"
ELECTRON_BUILDER_VER="${LATEST_ELECTRON_BUILDER_VER}"

inherit desktop xdg electron-r1

DESCRIPTION="Blockbench - A low poly 3D model editor"
HOMEPAGE="
	https://github.com/JannisX11/blockbench
	https://www.blockbench.net/
"
LICENSE="GPL-3"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/JannisX11/blockbench.git"
else
	SRC_URI="https://github.com/JannisX11/blockbench/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox mirror strip test"

RDEPEND="
	x11-libs/libnotify
	x11-misc/xdg-utils
	media-libs/imlib2
	media-libs/giblib
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
"

src_configure() {
	export COREPACK_ENABLE_STRICT=0
	npm set progress false
	npm i --force --loglevel verbose || die

	electron-r1_patch_electron_builder
}

src_compile() {
	npx electron-builder --dir || die
	cp "${FILESDIR}/blockbench.desktop" "${PN}.desktop"
	cp "${FILESDIR}/bbmodel.xml" "bbmodel.xml"
}

src_install() {
	domenu "${PN}.desktop"
	newicon build/icon.png "${PN}.png"

	insinto "/usr/share/mime/packages"
	doins bbmodel.xml

	cd dist/linux-unpacked/resources
	electron-r1_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
}
