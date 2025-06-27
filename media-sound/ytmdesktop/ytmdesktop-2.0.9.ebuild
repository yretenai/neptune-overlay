# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit electron-version

ELECTRON_SLOT="36"
ELECTRON_BUILDER_VER="${LATEST_ELECTRON_BUILDER_VER}"

inherit desktop xdg electron-r1

DESCRIPTION="A Desktop App for YouTube Music"
HOMEPAGE="https://github.com/ytmdesktop/ytmdesktop"
LICENSE="GPL-3"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ytmdesktop/ytmdesktop.git"
else
	SRC_URI="https://github.com/ytmdesktop/ytmdesktop/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	# Requires network access (https) as long as NPM dependencies aren't packaged
	RESTRICT="network-sandbox"
fi

RESTRICT="mirror test ${RESTRICT}"

RDEPEND="
	media-video/pipewire
	media-libs/libpulse
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	>=sys-apps/pnpm-bin-9.5.0
"

PATCHES=(
	"${FILESDIR}/${PN}-2.0.9-git.patch"
)

src_unpack() {
	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	else
		default
	fi

	cd "${S}"
	electron-r1_prep_npm

	export COREPACK_ENABLE_STRICT=0
	yarn config set --home enableTelemetry 0 || die
	yarn config set cacheFolder "${T}/yarn" || die
	mkdir "${T}/yarn" || die
	yarn install || die
}

src_prepare() {
	default
	sed -e "s/__PV__/${PV}/" -i viteconfig/renderer.ts -i viteconfig/main.ts || die
	sed -e "s|YTMD_DISABLE_UPDATES:|YTMD_DISABLE_UPDATES: true, //|" -i viteconfig/main.ts || die
}

src_configure() {
	electron-r1_patch_electron_builder
}

src_compile() {
	yarn run package
	electron-r1_src_compile
}

src_install() {
	newicon "src/assets/icons/ytmd.png" ${PN}.png

	make_desktop_entry "/usr/bin/${PN}" "YouTube Music Desktop" "${PN}" "Network;AudioVideo;Audio;Video"

	cd dist/"$(electron-r1_target)"/resources
	electron-r1_src_install

	if [[ "$ARCH" == "amd64" ]]; then
		cd "${S}/out/YouTube Music Desktop App-linux-x64/resources"
	elif [[ "$ARCH" == "x86" ]]; then
		cd "${S}/out/YouTube Music Desktop App-linux-ia32/resources"
	elif [[ "$ARCH" == "arm64" ]]; then
		cd "${S}/out/YouTube Music Desktop App-linux-arm64/resources"
	elif [[ "$ARCH" == "arm" ]]; then
		cd "${S}/out/YouTube Music Desktop App-linux-armv7l/resources"
	fi

	insinto "${ELECTRON_DESTDIR}/resources"
	doins *.png
	doins *.ico
}

pkg_postinst() {
	xdg_pkg_postinst
}
