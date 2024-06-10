# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Vesktop is a custom Discord App"
HOMEPAGE="https://github.com/Vencord
	https://github.com/Vencord/Vesktop
	https://vencord.dev/"

EGIT_REPO_URI="https://github.com/Vencord/Vesktop.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

inherit git-r3

LICENSE="GPL-3"
SLOT="0"
IUSE="appindicator +seccomp +wayland"

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox strip test"

RDEPEND="
	x11-libs/libnotify
	x11-misc/xdg-utils
	appindicator? ( dev-libs/libayatana-appindicator )
"

BDEPEND="
	>=net-libs/nodejs-20.6.1
	sys-apps/pnpm-bin
"

DESTDIR="/opt/${PN}"

src_prepare() {
	default

	export COREPACK_ENABLE_STRICT=0
	pnpm-bin config set store-dir "${T}/pnpm" || die
	sed -i -e "s/\"pnpm /\"pnpm-bin /" package.json || die
	sed -i -e "s|\"appId\":|\"electronDownload\": { \"cache\": \"${T}/electron\" },\"appId\":|" package.json || die
	pnpm-bin i || die
}

src_compile() {
	pnpm-bin package:dir || die
	cp "${FILESDIR}/vesktop.desktop" "${PN}.desktop"

	if ! use seccomp ; then
		sed -i "/Exec/s/${PN}/${PN} --disable-seccomp-filter-sandbox/" "${PN}.desktop" || die "sed failed for seccomp"
	fi

	if use wayland ; then
		sed -i "/Exec/s/${PN}/${PN} --ozone-platform-hint=auto --enable-wayland-ime/" "${PN}.desktop" || die "sed failed for wayland"
	fi
}

src_install() {
	domenu "${PN}.desktop"
	newicon static/icon.png vencord.png

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

	if use appindicator; then
		dosym ../../usr/lib64/libayatana-appindicator3.so "${DESTDIR}/libappindicator3.so"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
}