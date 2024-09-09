# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

inherit desktop optfeature xdg electron-builder-utils git-r3

DESCRIPTION="Revolt is an open source user-first chat platform."
HOMEPAGE="https://github.com/revoltchat
	https://github.com/revoltchat/desktop
	https://revolt.chat/"

LICENSE="Apache-2.0 MIT CC0-1.0 0BSD ISC BSD BSD-2 PSF-2 WTFPL"
SLOT="0"
IUSE="appindicator +seccomp +wayland"

EGIT_SUBMODULES=()
EGIT_REPO_URI="https://github.com/revoltchat/desktop.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="${ELECTRON_KEYWORDS}"
fi

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	wayland? ( dev-libs/wayland )
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
	appindicator? ( dev-libs/libayatana-appindicator )
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	sys-apps/yarn
	${ELECTRON_BDEPEND}
"

DESTDIR="/opt/${PN}"
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

	cd dist/linux-unpacked || die

	mv "revolt-desktop" "${PN}"

	exeinto "${DESTDIR}"

	doexe "${PN}" chrome-sandbox libEGL.so libffmpeg.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1

	insinto "${DESTDIR}"
	doins chrome_100_percent.pak chrome_200_percent.pak icudtl.dat resources.pak snapshot_blob.bin v8_context_snapshot.bin vk_swiftshader_icd.json
	insopts -m0755
	doins -r locales resources

	# Chrome-sandbox requires the setuid bit to be specifically set.
	# see https://github.com/electron/electron/issues/17972
	fowners root "${DESTDIR}/chrome-sandbox"
	fperms 4711 "${DESTDIR}/chrome-sandbox"

	dosym "${DESTDIR}/${PN}" "/usr/bin/${PN}"

	# Crashpad is included in the package once in a while and when it does, it must be installed.
	# See #903616 and #890595
	[[ -x chrome_crashpad_handler ]] && doins chrome_crashpad_handler

	if use appindicator; then
		dosym ../../usr/lib64/libayatana-appindicator3.so "${DESTDIR}/libappindicator3.so"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "sound support" \
		media-sound/pulseaudio media-sound/apulse[sdk] media-video/pipewire
}
