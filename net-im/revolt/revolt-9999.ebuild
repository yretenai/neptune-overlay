# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="${LATEST_ELECTRON_VER}"
ELECTRON_BUILDER_VER="24.13.3"

inherit desktop optfeature xdg electron git-r3

DESCRIPTION="Revolt is an open source user-first chat platform."
HOMEPAGE="https://github.com/revoltchat
	https://github.com/revoltchat/desktop
	https://revolt.chat/"
LICENSE="Apache-2.0 MIT CC0-1.0 0BSD ISC BSD BSD-2 PSF-2 WTFPL"
SLOT="0"

EGIT_SUBMODULES=()
EGIT_REPO_URI="https://github.com/revoltchat/desktop.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="${ELECTRON_KEYWORDS}"
fi

IUSE="+seccomp +wayland"

RDEPEND="
	${ELECTRON_RDEPEND}
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	sys-apps/yarn
"

DESTDIR="/usr/share/electron/apps/${P}"
QA_PREBUILT="${DESTDIR}/app.asar.unpacked/*"
RESTRICT="network-sandbox mirror strip test"

src_configure() {
	yarn config set --home enableTelemetry 0 || die
	yarn config set cacheFolder "${T}/yarn" || die
	mkdir "${T}/yarn" || die
	yarn install || die
}

src_compile() {
	yarn run build:bundle || die
	yarn run eb -l dir || die

	mv revolt-desktop.desktop "${PN}.desktop"

	if ! use seccomp ; then
		sed -i "/Exec/s/${PN}/${PN} --disable-seccomp-filter-sandbox/" "${PN}.desktop" || die "sed failed for seccomp"
	fi

	if use wayland ; then
		sed -i "/Exec/s/${PN}/${PN} --ozone-platform-hint=auto --enable-wayland-ime/" "${PN}.desktop" || die "sed failed for wayland"
	fi
}

src_install() {
	domenu "${PN}.desktop"
	newicon -s 256 "assets/icon.png" revolt-desktop.png

	cd dist/linux-unpacked/resources

	insinto "${DESTDIR}"
	doins -r *

	electron_dobin "${DESTDIR}/app.asar" "${PN}"
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "sound support" \
		media-sound/pulseaudio media-sound/apulse[sdk] media-video/pipewire
}
