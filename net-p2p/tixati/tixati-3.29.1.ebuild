# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

T_PV="$(ver_cut 1-2)-$(ver_cut 3-3)"

DESCRIPTION="Tixati is a New and Powerful P2P System"
HOMEPAGE="https://www.tixati.com/"
SRC_URI="https://download2.tixati.com/download/${PN}-${T_PV}.x86_64.manualinstall.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${T_PV}.x86_64.manualinstall/"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"

DEPEND="
	>=app-accessibility/at-spi2-core-2.48.3
	>=app-arch/brotli-1.1.0
	>=app-arch/bzip2-1.0.8-r4
	>=dev-libs/dbus-glib-0.112
	>=dev-libs/expat-2.5.0
	>=dev-libs/fribidi-1.0.13
	>=dev-libs/glib-2.76.4
	>=dev-libs/libffi-3.4.4-r1
	>=dev-libs/libpcre2-10.42-r1
	>=dev-libs/wayland-1.22.0
	>=media-gfx/graphite2-1.3.14_p20210810-r3
	>=media-libs/fontconfig-2.14.2-r3
	>=media-libs/freetype-2.13.2
	>=media-libs/harfbuzz-8.2.0
	>=media-libs/libepoxy-1.5.10-r2
	>=media-libs/libjpeg-turbo-3.0.0
	>=media-libs/libpng-1.6.40-r1
	>=sys-apps/dbus-1.15.6
	>=sys-apps/util-linux-2.38.1-r2
	>=sys-libs/glibc-2.37-r10
	>=sys-libs/zlib-1.2.13-r1
	>=x11-libs/cairo-1.17.8
	>=x11-libs/gdk-pixbuf-2.42.10-r1
	>=x11-libs/gtk+-3.24.38
	>=x11-libs/libX11-1.8.7
	>=x11-libs/libXau-1.0.11
	>=x11-libs/libXcomposite-0.4.6
	>=x11-libs/libXcursor-1.2.1
	>=x11-libs/libXdamage-1.1.6
	>=x11-libs/libXdmcp-1.1.4-r2
	>=x11-libs/libXext-1.3.5
	>=x11-libs/libXfixes-6.0.1
	>=x11-libs/libXi-1.8.1
	>=x11-libs/libXinerama-1.1.5
	>=x11-libs/libXrandr-1.5.3
	>=x11-libs/libXrender-0.9.11
	>=x11-libs/libxcb-1.16
	>=x11-libs/libxkbcommon-1.5.0
	>=x11-libs/pango-1.50.14
	>=x11-libs/pixman-0.42.2
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
