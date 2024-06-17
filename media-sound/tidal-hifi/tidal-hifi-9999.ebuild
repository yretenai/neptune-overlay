# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ELECTRON_VER="28.1.1"
ELECTRON_WVCUS="1"

inherit desktop xdg electron-builder-utils git-r3

DESCRIPTION="Web version of Tidal running in electron with Hi-Fi support thanks to Widevine."
HOMEPAGE="https://github.com/Mastermindzh/tidal-hifi"

EGIT_REPO_URI="https://github.com/Mastermindzh/tidal-hifi.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+seccomp +wayland"

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox strip test"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libgcrypt
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
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
"

BDEPEND="
	>=net-libs/nodejs-20.6.1
	${ELECTRON_BDEPEND}
"

DESTDIR="/opt/${PN}"

src_prepare() {
	default
	sed -i -e "s|electronDownload:|electronDownload:\n  cache: \"${DISTDIR}\"|" build/electron-builder.base.yml || die
}

src_configure() {
	export COREPACK_ENABLE_STRICT=0
	npm i || die
}

src_compile() {
	npm run build-unpacked || die
}

src_install() {
	newicon "build/icon.png" tidal-hifi.png

	EXEC="/usr/bin/tidal-hifi"

	if ! use seccomp ; then
		EXEC="${EXEC} --disable-seccomp-filter-sandbox"
	fi

	if use wayland ; then
		EXEC="${EXEC} --ozone-platform-hint=auto --enable-wayland-ime"
	fi

	make_desktop_entry "$EXEC" "TIDAL Hi-Fi" ${PN} "Network;AudioVideo;Audio;Video"

	cd dist/linux-unpacked

	exeinto "${DESTDIR}"
	doexe "${PN}" chrome-sandbox libEGL.so libffmpeg.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1
	[[ -x chrome_crashpad_handler ]] && doexe chrome_crashpad_handler

	insinto "${DESTDIR}"
	doins chrome_100_percent.pak chrome_200_percent.pak icudtl.dat resources.pak snapshot_blob.bin v8_context_snapshot.bin vk_swiftshader_icd.json
	insopts -m0755
	doins -r locales resources

	fowners root "${DESTDIR}/chrome-sandbox"
	fperms 4711 "${DESTDIR}/chrome-sandbox"

	dosym "${DESTDIR}/${PN}" "/usr/bin/${PN}"
}

pkg_postinst() {
	xdg_pkg_postinst
}
