# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="36"
ELECTRON_BUILDER_VER="${LATEST_ELECTRON_BUILDER_VER}"

inherit desktop xdg electron-r1

DESCRIPTION="Vesktop is a custom Discord App"
HOMEPAGE="https://github.com/Vencord
	https://github.com/Vencord/Vesktop
	https://vencord.dev/"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Vencord/Vesktop.git"
else
	SRC_URI="https://github.com/Vencord/Vesktop/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	S="${WORKDIR}/Vesktop-${PV}"
	# Requires network access (https) as long as NPM dependencies aren't packaged
	RESTRICT="network-sandbox"
fi

LICENSE="GPL-3"
SLOT="0"

RESTRICT="mirror test ${RESTRICT}"

RDEPEND="
	x11-libs/libnotify
	x11-misc/xdg-utils
	media-libs/libpulse
	media-video/pipewire
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	>=sys-apps/pnpm-bin-9.5.0
"

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
	else
		default
	fi

	cd "${S}"
	electron-r1_prep_npm

	export COREPACK_ENABLE_STRICT=0
	pnpm config set store-dir "${T}/pnpm" || die
	pnpm i --loglevel verbose --reporter append-only || die
}

src_configure() {
	electron-r1_patch_electron_builder
}

src_compile() {
	pnpm package:dir || die
	cp "${FILESDIR}/vesktop.desktop" "${PN}.desktop"
}

src_install() {
	domenu "${PN}.desktop"
	newicon static/icon.png vencord.png

	cd dist/"$(electron-r1_target)"/resources
	electron-r1_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
}
