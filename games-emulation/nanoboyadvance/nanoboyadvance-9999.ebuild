# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} python3_{13..14}t )
GLAD_PV="2.0.6"

inherit cmake git-r3 python-single-r1 xdg

DESCRIPTION="A cycle-accurate Nintendo Game Boy Advance emulator"
HOMEPAGE="https://github.com/nba-emu/NanoBoyAdvance"

EGIT_REPO_URI="https://github.com/nba-emu/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
IUSE="+gui"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	>=media-libs/libsdl2-2.0.10
	virtual/opengl
	media-libs/glew
	app-arch/unarr
	>=dev-libs/libfmt-12.1.0:=
	dev-qt/qtbase:6[gui,opengl,widgets]
	dev-qt/qt5compat:6
	${PYTHON_DEPS}
"
RDEPEND="${DEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/jinja2-2.7[${PYTHON_USEDEP}]
	')
	>=dev-cpp/toml11-4.4.0
	app-text/dos2unix
"

src_unpack() {
	default
	git-r3_src_unpack
}

src_prepare() {
	sed -e "s/unarr 1.1.0/unarr/" -i thirdparty/CMakeLists.txt
	sed -e "s/toml11 4.4.0/toml11/" -i thirdparty/CMakeLists.txt
	sed -e "s/fmt 12.1.0/fmt/" -i thirdparty/CMakeLists.txt
	default
	cmake_prepare
}

src_configure() {
	local mycmakeargs=(
		-DPORTABLE_MODE=OFF
		-DBUILD_SHARED_LIBS=OFF
		-DPLATFORM_QT=$(usex gui)
	)

	cmake_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
