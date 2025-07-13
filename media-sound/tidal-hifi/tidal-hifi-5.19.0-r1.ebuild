# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="${LATEST_ELECTRON_VER}"
ELECTRON_BUILDER_VER="${LATEST_ELECTRON_BUILDER_VER}"
ELECTRON_WIDEVINE="1"

inherit desktop xdg electron-r1

DESCRIPTION="Web version of Tidal running in electron with Hi-Fi support thanks to Widevine."
HOMEPAGE="https://github.com/Mastermindzh/tidal-hifi"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Mastermindzh/tidal-hifi.git"
else
	SRC_URI="https://github.com/Mastermindzh/tidal-hifi/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	# Requires network access (https) as long as NPM dependencies aren't packaged
	RESTRICT="network-sandbox"
fi

RESTRICT="mirror test ${RESTRICT}"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
"

src_unpack() {
	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	else
		default
	fi

	cd "${S}"
	electron-r1_prep_npm

	export COREPACK_ENABLE_STRICT=0
	npm set progress false
	npm i --loglevel verbose || die
}

src_prepare() {
	default

	sed -i -e "s|electronDownload:|electronDist: \"${ELECTRON_PATH}\"\nelectronDownload:\n  cache: \"${DISTDIR}\"|" build/electron-builder.base.yml || die
	sed -i -e "s|electronVersion:.*$|electronVersion: ${ELECTRON_VER_BASE}|" build/electron-builder.base.yml || die
	sed -i -e "s|version: .*+wvcus|version: ${ELECTRON_VER}|" build/electron-builder.base.yml || die
}

src_configure() {
	electron-r1_patch_electron_builder
}

src_compile() {
	npm run build-unpacked || die
}

src_install() {
	newicon "build/icon.png" ${PN}.png

	make_desktop_entry "/usr/bin/${PN}" "TIDAL Hi-Fi" "${PN}" "Network;AudioVideo;Audio;Video"

	cd dist/"$(electron-r1_target)"/resources
	electron-r1_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
}
