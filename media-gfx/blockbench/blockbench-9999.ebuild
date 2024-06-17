# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

ELECTRON_VER="31.0.1"

DESCRIPTION="Blockbench - A low poly 3D model editor"
HOMEPAGE="https://github.com/JannisX11/blockbench
	https://www.blockbench.net/"

EGIT_REPO_URI="https://github.com/JannisX11/blockbench.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~arm64 ~arm"
fi

SRC_URI="
	amd64? ( https://github.com/electron/electron/releases/download/v${ELECTRON_VER}/electron-v${ELECTRON_VER}-linux-x64.zip )
	arm64? ( https://github.com/electron/electron/releases/download/v${ELECTRON_VER}/electron-v${ELECTRON_VER}-linux-arm64.zip )
	arm? ( https://github.com/electron/electron/releases/download/v${ELECTRON_VER}/electron-v${ELECTRON_VER}-linux-armv7l.zip )
"

inherit git-r3

LICENSE="GPL-3"
SLOT="0"
IUSE="+seccomp +wayland"

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox strip test"

RDEPEND="
	x11-libs/libnotify
	x11-misc/xdg-utils
"

BDEPEND="
	>=net-libs/nodejs-20.6.1
	app-misc/jq
"

DESTDIR="/opt/${PN}"

src_unpack() {
	git-r3_src_unpack
}

src_prepare() {
	default
	
	export COREPACK_ENABLE_STRICT=0

	echo "$(jq --arg cache "${DISTDIR}" '.build.electronDownload.cache = $cache' package.json)" > package.json
	echo "$(jq 'del(.dependencies.electron)' package.json)" > package.json
	echo "$(jq --arg version "${ELECTRON_VER}" '.devDependencies.electron = $version' package.json)" > package.json
	
	npm i || die
}

src_compile() {
	npx electron-builder --dir || die
	cp "${FILESDIR}/blockbench.desktop" "${PN}.desktop"
	cp "${FILESDIR}/bbmodel.xml" "bbmodel.xml"

	if ! use seccomp ; then
		sed -i "/Exec/s/${PN}/${PN} --disable-seccomp-filter-sandbox/" "${PN}.desktop" || die "sed failed for seccomp"
	fi

	if use wayland ; then
		sed -i "/Exec/s/${PN}/${PN} --ozone-platform-hint=auto --enable-wayland-ime/" "${PN}.desktop" || die "sed failed for wayland"
	fi
}

src_install() {
	domenu "${PN}.desktop"
	newicon build/icon.png "${PN}.png"
	
	insinto "/usr/share/mime/packages"
	doins bbmodel.xml

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