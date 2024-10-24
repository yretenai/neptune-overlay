# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="${LATEST_ELECTRON_VER}"
ELECTRON_BUILDER_VER="${LATEST_ELECTRON_BUILDER_VER}"

inherit desktop xdg electron git-r3

DESCRIPTION="Vesktop is a custom Discord App"
HOMEPAGE="https://github.com/Vencord
	https://github.com/Vencord/Vesktop
	https://vencord.dev/"

EGIT_REPO_URI="https://github.com/Vencord/Vesktop.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="-* ~amd64 ~arm64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="+seccomp +wayland"

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox mirror strip test"

RDEPEND="
	${ELECTRON_RDEPEND}
	x11-libs/libnotify
	x11-misc/xdg-utils
	media-libs/libpulse
	media-video/pipewire
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	>=sys-apps/pnpm-bin-9.5.0
"

DESTDIR="/usr/share/electron/apps/${P}"
QA_PREBUILT="${DESTDIR}/app.asar.unpacked/*"

src_prepare() {
	electron_src_prepare
}

src_configure() {
	export COREPACK_ENABLE_STRICT=0
	pnpm config set store-dir "${T}/pnpm" || die
	pnpm i || die
}

src_compile() {
	pnpm package:dir || die
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

	cd dist/linux-unpacked/resources

	# todo: build this manually.
	if [[ "$ARCH" == "amd64" ]]; then
		rm -rfv "app.asar.unpacked/node_modules/@vencord/venmic/prebuilds/venmic-addon-linux-arm64/"
	elif [[ "$ARCH" == "arm64" ]]; then
		rm -rfv "app.asar.unpacked/node_modules/@vencord/venmic/prebuilds/venmic-addon-linux-x64/"
	fi

	insinto "${DESTDIR}"
	doins -r *

	electron_dobin "${DESTDIR}/app.asar" "${PN}"
}

pkg_postinst() {
	xdg_pkg_postinst
}
