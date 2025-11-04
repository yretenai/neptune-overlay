# Copyright 2019-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs xdg

MY_PV="${PV//_/}"

DESCRIPTION="Nintendo DS emulator, sorta"
HOMEPAGE="http://melonds.kuribo64.net
	https://github.com/Arisotura/melonDS"

if [[ "${PV}" == *9999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/melonDS-emu/${PN}.git"
else
	SRC_URI="https://github.com/melonDS-emu/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz"
	S="${WORKDIR}/melonDS-${MY_PV}"

	KEYWORDS="~amd64"
fi

LICENSE="BSD-2 GPL-2 GPL-3 Unlicense"
SLOT="0"
IUSE="+jit +gui lto gdb +opengl wayland"

RDEPEND="
	app-arch/libarchive
	gui? (
		media-libs/libsdl2[sound,video]
		dev-qt/qtbase:6[gui,network,opengl,widgets]
		dev-qt/qtmultimedia:6
		dev-qt/qtsvg:6
	)
	net-libs/enet:=
	net-libs/libpcap
	net-libs/libslirp
	wayland? (
		dev-libs/wayland
	)
	gdb? (
		dev-debug/gdb
	)
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	wayland? (
		kde-frameworks/extra-cmake-modules:0
	)
"

REQUIRED_USE="
	wayland? ( gui )
"

PATCHES=(
	"${FILESDIR}/${PN}-${PV}-std_optional.patch"
)

# used for JIT recompiler
QA_EXECSTACK="usr/bin/melonDS"

src_configure() {
	local -a mycmakeargs=(
		-DENABLE_JIT="$(usex jit)"
		-DENABLE_JIT_PROFILING=OFF # requires VTune
		-DENABLE_LTO_RELEASE="$(usex lto)"
		-DENABLE_LTO="$(usex lto)"
		-DENABLE_OGLRENDERER="$(usex opengl)"
		-DENABLE_WAYLAND="$(usex wayland)"
		-DENABLE_GDBSTUB="$(usex gdb)"
		-DBUILD_QT_SDL="$(usex gui)"
		-DUSE_QT6="ON"
		-DUSE_SYSTEM_LIBSLIRP=ON
	)

	cmake_src_configure
}

src_compile() {
	tc-export AR
	cmake_src_compile
}

src_install() {
	cmake_src_install
}

pkg_postinst() {
	xdg_pkg_postinst

	elog
	elog "You need the following files in order to run melonDS:"
	elog "\tbios7.bin"
	elog "\tbios9.bin"
	elog "\tfirmware.bin"
	elog "Place them in \"~/.config/melonDS\" or"
	elog "modify your melonDS configuration to point to the files"
	elog
}

pkg_postrm() {
	xdg_pkg_postrm
}
