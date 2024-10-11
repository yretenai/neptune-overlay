# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="a highly automated and intuitive digital audio workstation"
HOMEPAGE="
	https://www.zrythm.org
	https://gitlab.zrythm.org/zrythm/zrythm
"

MY_PV_VER="${PV:0-1}"
MY_PV="${PV%_*}-rc.${MY_PV_VER}"
MY_PV_ZIP="${PV%_*}.rc.${MY_PV_VER}"

SRC_URI="https://github.com/zrythm/zrythm/releases/download/v${MY_PV}/${PN}-${MY_PV_ZIP}-installer.zip -> ${P}.zip"
S="${WORKDIR}/${PN}-${MY_PV_ZIP}-installer/opt/${PN}-${MY_PV_ZIP}"
LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+man"
RESTRICT="mirror strip"
QA_PREBUILT="*"

src_install() {
	domenu "share/applications/org.zrythm.Zrythm.desktop"
	doicon -s scalable "share/icons/hicolor/scalable/apps/org.zrythm.Zrythm.svg"
	
	if use man; then
		doman "share/man/man1/zrythm.1"
	fi

	insinto "/usr/share/metainfo"
	doins "share/metainfo/org.zrythm.Zrythm.appdata.xml"

	insinto "/usr/share/mime/application"
	doins "share/mime/packages/org.zrythm.Zrythm-mime.xml"

	exeinto "/opt/${PN}-${MY_PV_ZIP}/bin"

	doexe \
		bin/zrythm \
		bin/zrythm_gdb \
		bin/zrythm_launch \
		bin/zrythm_valgrind

	insinto "/opt/${PN}-${MY_PV_ZIP}"

	# this is dirty, a lot of these libraries already exist in system but there's heaps.
	# todo: figure out which exist
	doins -r etc share lib
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}

