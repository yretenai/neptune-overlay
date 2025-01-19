# Copyright 2023-2024 Gentoo Authors
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
	KEYWORDS="~amd64"
fi

IUSE="+seccomp +wayland"

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
	${FILESDIR}/${PN}-${PV}-disable-updates.patch
	${FILESDIR}/${PN}-${PV}-disable-devtools.patch
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

	EXEC="/usr/bin/${PN}"

	if ! use seccomp ; then
		EXEC="${EXEC} --disable-seccomp-filter-sandbox"
	fi

	if use wayland ; then
		EXEC="${EXEC} --ozone-platform-hint=auto --enable-wayland-ime"
	fi

	make_desktop_entry "$EXEC" "YouTube Music" "${PN}" "Network;AudioVideo;Audio;Video"

	cd pack/linux-unpacked/resources
	electron-r1_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
}
