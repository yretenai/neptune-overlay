# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

T_PV="$(ver_cut 1-2)-1"

DESCRIPTION="Tixati is a New and Powerful P2P System"
HOMEPAGE="https://www.tixati.com/"
SRC_URI="https://download.tixati.com/${PN}-${T_PV}.x86_64.manualinstall.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${T_PV}.x86_64.manualinstall/"

LICENSE="tixati"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	app-accessibility/at-spi2-core
	app-arch/brotli
	app-arch/bzip2
	dev-libs/glib[dbus]
	media-gfx/graphite2
	sys-libs/zlib
	x11-libs/gtk+:2[xinerama,introspection]
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-libs/pixman
"

RESTRICT="bindist mirror"
QA_PREBUILT="usr/bin/tixati"

src_install() {
	exeinto /usr/bin/
	doexe tixati
	sed -i 's/Internet/X-Internet/' tixati.desktop || die
	domenu tixati.desktop
	doicon -s 48 tixati.png
}
