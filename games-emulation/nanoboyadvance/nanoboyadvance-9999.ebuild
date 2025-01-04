# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
GLAD_PV="2.0.6"

inherit cmake git-r3 python-single-r1 xdg-utils

DESCRIPTION="A cycle-accurate Nintendo Game Boy Advance emulator"
HOMEPAGE="https://github.com/nba-emu/NanoBoyAdvance"
LICENSE="GPL-3"
SLOT="0"

EGIT_REPO_URI="https://github.com/nba-emu/${PN}.git"

SRC_URI="https://github.com/Dav1dde/glad/archive/refs/tags/v${GLAD_PV}.tar.gz -> glad-${GLAD_PV}.tar.gz"

IUSE="qt6 +qt5 +gui"
REQUIRED_USE="^^ ( qt6 qt5 ) ${PYTHON_REQUIRED_USE}"

DEPEND="
	>=media-libs/libsdl2-2.0.10
	virtual/opengl
	media-libs/glew
	app-arch/unarr
	>=dev-libs/libfmt-8.0.1:=
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/qtopengl:5
	)
	qt6? (
		dev-qt/qtbase:6[gui,opengl,widgets]
		dev-qt/qt5compat:6
	)
	${PYTHON_DEPS}
"
RDEPEND="${DEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/jinja2-2.7[${PYTHON_USEDEP}]
	')
	>=dev-cpp/toml11-3.7
"

PATCHES=(
	"${FILESDIR}/${PN}-${PV}-toml11.patch"
)

src_unpack() {
	default
	git-r3_src_unpack
}

src_configure() {
	sed -e "s|find_package(Python |find_package(Python ${EPYTHON:6} EXACT |" -i "${WORKDIR}/glad-${GLAD_PV}/cmake/GladConfig.cmake" || die

	local mycmakeargs=(
		-DPORTABLE_MODE=OFF
		-DBUILD_SHARED_LIBS=OFF
		-DUSE_QT6=$(usex qt6)
		-DPLATFORM_QT=$(usex gui)
		-DUSE_SYSTEM_TOML11=ON
		-DUSE_SYSTEM_UNARR=ON
		-DUSE_SYSTEM_FMT=ON
		-DRELEASE_BUILD=ON
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_QUIET=OFF
		-DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS
		-DFETCHCONTENT_SOURCE_DIR_GLAD="${WORKDIR}/glad-${GLAD_PV}"
	)

	cmake_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
