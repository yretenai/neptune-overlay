# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

HYTALE_VERSION="2026.02.19-a3ce7ff"

inherit desktop xdg
DESCRIPTION="A sandbox block game"
HOMEPAGE="https://hytale.com/"
SRC_URI="https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-${HYTALE_VERSION}.zip -> ${P}_${HYTALE_VERSION}.zip"

S="${WORKDIR}"
LICENSE="Hytale"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist strip mirror"
QA_PREBUILT="*"

BDEPEND="
	app-arch/unzip
"
RDEPEND="
	net-libs/webkit-gtk:4.1
	media-libs/alsa-lib
	dev-libs/icu
	dev-libs/openssl
	virtual/udev
	virtual/opengl
	media-libs/libglvnd
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
"

src_install() {
	exeinto "/opt/${PN}"
	doexe hytale-launcher
	dosym "/opt/${PN}/hytale-launcher" /usr/bin/hytale-launcher
	doicon "${FILESDIR}/hytale.png"
	make_desktop_entry --eapi9 "hytale-launcher" -n "Hytale Launcher" -i "hytale" -c "Game"
}

pkg_postrm() {
	ewarn ""
	ewarn "The Hytale launcher will download java and client files to:"
	ewarn "\t~/.local/share/Hytale (or \$XDG_DATA_HOME/Hytale)"
	ewarn "If you no longer desire to use Hytale;"
	ewarn "After removal it is safe to remove that directory."
	ewarn ""
}
