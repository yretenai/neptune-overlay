# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Production render farm manager from Blender Studio"
HOMEPAGE="
	https://projects.blender.org/studio/flamenco
"
LICENSE="GPL-3"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://projects.blender.org/studio/flamenco.git"
else
	SRC_URI="
		https://projects.blender.org/studio/flamenco/archive/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/yretenai/neptune-overlay/releases/download/deps/${P}-deps.tar.xz
	"
	S="${WORKDIR}/${PN}"
	KEYWORDS="~amd64 ~arm64"
fi

RDEPEND="
	>=media-video/ffmpeg-5.1
"

BDEPEND="
	net-libs/nodejs[npm]
	sys-apps/yarn
	app-arch/zip
"

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox mirror test"

PATCHES=(
	"${FILESDIR}/flamenco-3.6-no-exe-dir.patch"
)

if [[ "${PV}" != *9999* ]]; then
	PATCHES+=(
		"${FILESDIR}/flamenco-3.6-git.patch"
	)
fi

src_unpack() {
	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	else
		default
	fi

	yarn config set --home enableTelemetry 0 || die
	yarn config set cacheFolder "${T}/yarn" || die
	mkdir "${T}/yarn" || die

	cd "${S}/web/app"
	yarn install || die
}

src_compile() {
	cd "${S}/web/app"
	# https://projects.blender.org/studio/flamenco/src/tag/v3.6/magefiles/build.go#L75
	yarn build --outDir ../static --base=/app/ --logLevel warn || die

	cd "${S}/addon"
	zip -r ../web/static/flamenco-addon.zip flamenco

	cd "${S}"
	# strip ldflags because flamenco pulls that variable for some reason
	LDFLAGS="" emake flamenco-manager-without-webapp flamenco-worker
}

src_install() {
	dobin flamenco-manager flamenco-worker
	dodoc CHANGELOG.md README.md
}

pkg_postinst() {
	ewarn
	ewarn "Flamenco creates directories relative to the working directory of the shell that executed it"
	ewarn "Be sure to run the command in a safe location"
	ewarn
}
