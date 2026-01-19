# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="${LATEST_ELECTRON_VER}"
ELECTRON_BUILDER_VER="${LATEST_ELECTRON_BUILDER_VER}"
ELECTRON_UNSTABLE=1 # uses electron beta

inherit desktop xdg electron-r1

DESCRIPTION="Pear Desktop is extension for music player"
HOMEPAGE="https://github.com/pear-devs/pear-desktop"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/pear-devs/pear-desktop.git"
else
	SRC_URI="https://github.com/pear-devs/pear-desktop/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	# Requires network access (https) as long as NPM dependencies aren't packaged
	RESTRICT="network-sandbox"
fi

RESTRICT="mirror test ${RESTRICT}"
RESTRICT+="network-sandbox"

RDEPEND="
	media-video/pipewire
	media-libs/libpulse
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	>=sys-apps/pnpm-bin-9.5.0
"

PATCHES="
	${FILESDIR}/${PN}-9999-fixup.patch
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
	pnpm config set store-dir "${T}/pnpm" || die
	pnpm i --loglevel verbose --reporter append-only || die
}

src_configure() {
	electron-r1_patch_electron_builder
}

src_compile() {
	pnpm build || die
	electron-r1_src_compile
}

src_install() {
	# newicon "docs/favicon/favicon_144.png" ${PN}.png

	make_desktop_entry "/usr/bin/${PN}" "Pear Desktop" "youtube-music" "Network;AudioVideo;Audio;Video"

	cd pack/"$(electron-r1_target)"
	insinto "${ELECTRON_DESTDIR}"
	mv "youtube-music" "pear-desktop"
	doins -r .
	chmod 0755 "${ED}${ELECTRON_DESTDIR}/pear-desktop"

	cd resources
	electron-r1_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
}
