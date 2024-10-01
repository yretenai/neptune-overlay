# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/-bin/}"
MY_PV="${PV/-r*/}"

inherit desktop unpacker xdg

DESCRIPTION="Organize and execute REST requests in a simple and intuitive app"
HOMEPAGE="https://yaak.app"
SRC_URI="https://github.com/yaakapp/app/releases/download/v${MY_PV}/yaak_${MY_PV}_amd64.deb"

S="${WORKDIR}/usr"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* amd64"
RESTRICT="bindist mirror strip test"

RDEPEND="
	dev-libs/libayatana-appindicator
	gnome-base/librsvg:2
	net-libs/webkit-gtk:4.1
"

QA_PREBUILT="*"

src_unpack() {
	unpack_deb "yaak_${MY_PV}_amd64.deb"
}

src_install() {
	doicon "share/icons/hicolor/256x256@2/apps/${MY_PN}-app.png"
	domenu "share/applications/${MY_PN}-app.desktop"

	insinto "/usr/lib/yaak-app"
	doins -r lib/yaak-app/*

	cd bin
	dobin yaak-app yaaknode yaakprotoc
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
