# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="${LATEST_ELECTRON_VER}"
ELECTRON_BUILDER_VER="${LATEST_ELECTRON_BUILDER_VER}"

inherit desktop xdg electron-r1

DESCRIPTION="YouTube Music Desktop App bundled with custom plugins"
HOMEPAGE="https://github.com/th-ch/youtube-music"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/th-ch/youtube-music.git"
else
	SRC_URI="https://github.com/th-ch/youtube-music/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
fi

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox mirror strip test"

RDEPEND="
	media-video/pipewire
	media-libs/libpulse
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	>=sys-apps/pnpm-bin-9.5.0
"

PATCHES="
	${FILESDIR}/${PN}-3.7.2-disable-updates.patch
	${FILESDIR}/${PN}-3.7.2-disable-devtools.patch
"

src_prepare() {
	default
	echo "$(jq '.pnpm.overrides.nan = "2.22.0"' package.json)" > package.json
}

src_configure() {
	export COREPACK_ENABLE_STRICT=0
	pnpm config set store-dir "${T}/pnpm" || die
	pnpm i --loglevel verbose --reporter append-only || die

	electron-r1_patch_electron_builder
}

src_compile() {
	pnpm build || die
	electron-r1_src_compile
}

src_install() {
	newicon "assets/youtube-music.svg" ${PN}.svg

	make_desktop_entry "/usr/bin/${PN}" "YouTube Music" "${PN}" "Network;AudioVideo;Audio;Video"

	cd pack/"$(electron-r1_target)"/resources
	electron-r1_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
}
