# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="${LATEST_ELECTRON_WVCUS_VER}"
ELECTRON_BUILDER_VER="${LATEST_ELECTRON_BUILDER_VER}"
ELECTRON_WVCUS="1"

inherit desktop xdg electron git-r3

DESCRIPTION="Web version of Tidal running in electron with Hi-Fi support thanks to Widevine."
HOMEPAGE="https://github.com/Mastermindzh/tidal-hifi"
LICENSE="MIT"
SLOT="0"

EGIT_REPO_URI="https://github.com/Mastermindzh/tidal-hifi.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="${PV}"
	KEYWORDS="${ELECTRON_KEYWORDS}"
fi

IUSE="+seccomp +wayland"

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox mirror strip test"

RDEPEND="
	${ELECTRON_RDEPEND}
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
"

DESTDIR="/usr/share/electron/apps/${P}"
QA_PREBUILT="${DESTDIR}/app.asar.unpacked/*"

src_prepare() {
	default
	sed -i -e "s|electronDownload:|electronDist: \"/usr/share/electron-wvcus/${ELECTRON_SLOT}\"\nelectronDownload:\n  cache: \"${DISTDIR}\"|" build/electron-builder.base.yml || die
	sed -i -e "s|electronVersion:.*$|electronVersion: ${ELECTRON_VER_BASE}|" build/electron-builder.base.yml || die
	sed -i -e "s|version: .*+wvcus|version: ${ELECTRON_VER}|" build/electron-builder.base.yml || die
}

src_configure() {
	export COREPACK_ENABLE_STRICT=0
	npm i || die
}

src_compile() {
	npm run build-unpacked || die
}

src_install() {
	newicon "build/icon.png" ${PN}.png

	EXEC="/usr/bin/${PN}"

	if ! use seccomp ; then
		EXEC="${EXEC} --disable-seccomp-filter-sandbox"
	fi

	if use wayland ; then
		EXEC="${EXEC} --ozone-platform-hint=auto --enable-wayland-ime"
	fi

	make_desktop_entry "$EXEC" "TIDAL Hi-Fi" "${PN}" "Network;AudioVideo;Audio;Video"

	cd dist/linux-unpacked/resources

	insinto "${DESTDIR}"
	doins -r *

	electron_dobin "${DESTDIR}/app.asar" "${PN}"
}

pkg_postinst() {
	xdg_pkg_postinst
}
