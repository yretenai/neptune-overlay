# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Electron"

MY_PN="${PN/-bin*/}"
MY_PV="${PV/-r*/}"

SRC_URI="
	debug? (
		amd64? ( https://github.com/electron/electron/releases/download/v${MY_PV}/electron-v${MY_PV}-linux-x64-debug.zip )
		arm64? ( https://github.com/electron/electron/releases/download/v${MY_PV}/electron-v${MY_PV}-linux-arm64-debug.zip )
		arm? ( https://github.com/electron/electron/releases/download/v${MY_PV}/electron-v${MY_PV}-linux-armv7l-debug.zip )
	)
	amd64? ( https://github.com/electron/electron/releases/download/v${MY_PV}/electron-v${MY_PV}-linux-x64.zip )
	arm64? ( https://github.com/electron/electron/releases/download/v${MY_PV}/electron-v${MY_PV}-linux-arm64.zip )
	arm? ( https://github.com/electron/electron/releases/download/v${MY_PV}/electron-v${MY_PV}-linux-armv7l.zip )
"
KEYWORDS="-* ~amd64 ~arm ~arm64"

SLOT="$(ver_cut 1)"
RESTRICT="mirror test"
IUSE="debug wayland X appindicator"
REQUIRED_USE="
	|| ( wayland X )
"
DESTDIR="/usr/share/${MY_PN}/${SLOT}"
S="${WORKDIR}"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-libs/glibc
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X?,wayland?]
	x11-libs/pango
	appindicator? ( dev-libs/libayatana-appindicator )
"

src_install() {
	exeinto "${DESTDIR}"
	doexe "${MY_PN}" chrome-sandbox libEGL.so libffmpeg.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1
	[[ -x chrome_crashpad_handler ]] && doexe chrome_crashpad_handler

	insinto "${DESTDIR}"
	doins chrome_100_percent.pak chrome_200_percent.pak icudtl.dat resources.pak snapshot_blob.bin v8_context_snapshot.bin vk_swiftshader_icd.json icudtl.dat version
	insopts -m0755
	doins -r locales resources

	if use debug; then
		cd debug
		doins -r *.debug
	fi

	dosym "${DESTDIR}/${MY_PN}" "/usr/bin/${MY_PN}-${SLOT}"

	# this kills electron-builder, need to figure out how to do this cleanly...
	# fowners root "${DESTDIR}/chrome-sandbox"
	# fperms 4711 "${DESTDIR}/chrome-sandbox"

	if use appindicator; then
		dosym "/usr/$(get_libdir)/libayatana-appindicator3.so" "${DESTDIR}/libappindicator3.so"
	fi
}
