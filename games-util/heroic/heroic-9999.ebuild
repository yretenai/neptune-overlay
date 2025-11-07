# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="${LATEST_ELECTRON_VER}"
ELECTRON_BUILDER_VER="${LATEST_ELECTRON_BUILDER_VER}"

inherit desktop xdg electron-r1

DESCRIPTION="An Open Source Games Launcher"
HOMEPAGE="https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher.git"
else
	SRC_URI="https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	S="${WORKDIR}/HeroicGamesLauncher-${PV}"
fi

LICENSE="GPL-3"
SLOT="0"

# Requires network access (https) since node-gyp downloads headers?
RESTRICT="mirror test network-sandbox ${RESTRICT}"

RDEPEND="
	x11-libs/libnotify
	x11-misc/xdg-utils
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	>=sys-apps/pnpm-bin-9.5.0
"

src_unpack() {
	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	else
		default
	fi

	cd "${S}"
	electron-r1_prep_npm
	eapply "${FILESDIR}/heroic-2.18.1-remove-patches.patch"
	echo "$(jq --arg version "^4.17.0" '.pnpm.overrides["node-abi"] = $version' package.json)" > package.json
	echo "$(jq --arg version "^8.5.0" '.pnpm.overrides["node-addon-api"] = $version' package.json)" > package.json

	rm pnpm-lock.yaml

	export COREPACK_ENABLE_STRICT=0
	pnpm config set store-dir "${T}/pnpm" || die
	pnpm i --loglevel verbose --reporter append-only || die
	pnpm download-helper-binaries
}

src_configure() {
	electron-r1_patch_electron_builder
}

src_compile() {
	pnpm npx electron-vite build || die
	pnpm npx electron-builder --dir || die
	cp "${FILESDIR}/${PN}.desktop" "${PN}.desktop"
}

src_install() {
	domenu "${PN}.desktop"
	newicon public/icon.png ${PN}.png

	cd dist/"$(electron-r1_target)"/resources
	electron-r1_src_install
	find "${ED}${ELECTRON_DESTDIR}resources/app.asar.unpacked/build/bin" -type f -exec chmod +x {} \; || die
}

pkg_postinst() {
	xdg_pkg_postinst
}
