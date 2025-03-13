# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo desktop xdg

DESCRIPTION="Yet another matrix client for desktop"
HOMEPAGE="
	https://github.com/cinnyapp/cinny-desktop
	https://github.com/cinnyapp/cinny
	https://cinny.in/
"

S="${WORKDIR}/${P}"

LICENSE="AGPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD Boost-1.0 MIT MPL-2.0 Unicode-DFS-2016
	|| ( CC0-1.0 MIT-0 )
"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3 
	EGIT_REPO_URI="https://github.com/cinnyapp/cinny-desktop.git"
else
	SRC_URI="
		https://github.com/cinnyapp/cinny/archive/refs/tags/v${PV}.tar.gz -> cinny-${PV}.tar.gz
		https://github.com/cinnyapp/cinny-desktop/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/yretenai/neptune-overlay/releases/download/deps/cinny-desktop-${PV}-crates.tar.xz
	"
	KEYWORDS="~amd64"
fi
S_CINNY="${S}/cinny"
S_TAURI="${S}/src-tauri"

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox mirror test"

DEPEND="
	net-libs/webkit-gtk:4
	dev-libs/libayatana-appindicator
	gnome-base/librsvg
"

BDEPEND="
	>=net-libs/nodejs-16.0.0[npm]
"

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
		cargo_live_src_unpack
	else
		cargo_src_unpack
	fi
}

src_prepare() {
	rmdir "${S_CINNY}"
	mv "${WORKDIR}/cinny-${PV}" "${S_CINNY}"

	default
}

src_configure() {
	cd "${S_CINNY}"
	npm ci || die

	cd "${S_TAURI}"
	cargo_src_configure
}

src_compile() {
	cd "${S_CINNY}"
	npm run build || die

	cd "${S_TAURI}"
	cargo_src_compile
}

src_install() {
	cd "${S_TAURI}"
	cargo_src_install
	make_desktop_entry cinny Cinny cinny "Network;InstantMessaging"
	newicon "icons/icon.png" cinny.png
}
