# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/-bin/}"
MY_PV="${PV/-r*/}"

inherit desktop unpacker xdg

DESCRIPTION="Spacedrive is an open source cross-platform file explorer, powered by a virtual distributed filesystem written in Rust."
HOMEPAGE="https://www.spacedrive.com/"
SRC_URI="https://github.com/spacedriveapp/${MY_PN}/releases/download/${MY_PV}/${MY_PN^}-linux-x86_64.deb -> ${MY_PN^}.deb"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="bindist mirror strip test"
IUSE="heif ffmpeg pdf"

RDEPEND="
	sys-libs/glibc
	x11-libs/cairo
	ffmpeg? ( media-video/ffmpeg )
	x11-libs/gdk-pixbuf:2
	dev-libs/glib:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	heif? ( media-libs/libheif )
	dev-libs/openssl
	net-libs/webkit-gtk:4/37
	net-libs/libsoup:2.4
"

# TODO: spacedrive uses libpdfium, we could use the provided libpdfium.so but i don't want to.

QA_PREBUILT="*"

S="${WORKDIR}"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	exeinto /usr/bin
	doexe usr/bin/${MY_PN}
	if use pdf; then
		exeinto /usr/lib/spacedrive
		doexe usr/lib/spacedrive/libpdfium.so
	fi

	insinto /usr
	gzip -d usr/share/man/man1/${MY_PN}.1.gz || die
	doman usr/share/man/man1/${MY_PN}.1 && rm usr/share/man/man1/${MY_PN}.1
	rm -rf usr/share/doc
	doins -r usr/share
}
