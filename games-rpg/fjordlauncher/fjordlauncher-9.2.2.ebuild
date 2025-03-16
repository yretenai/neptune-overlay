# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake java-pkg-2 optfeature xdg

DESCRIPTION="Prism Launcher fork with support for alternative auth servers"
HOMEPAGE="https://github.com/unmojang/FjordLauncher"

NBTPLUSPLUS_COMMIT=23b955121b8217c1c348a9ed2483167a6f3ff4ad
SRC_URI="
	https://github.com/unmojang/FjordLauncher/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/PrismLauncher/libnbtplusplus/archive/${NBTPLUSPLUS_COMMIT}.tar.gz -> ${PN}-nbtplusplus-${NBTPLUSPLUS_COMMIT}.tar.gz
"
S="${WORKDIR}/FjordLauncher-${PV}"
KEYWORDS="~amd64 ~arm64"
LICENSE="Apache-2.0 BSD BSD-2 GPL-2+ GPL-3 ISC LGPL-2.1+ LGPL-3+ MIT"
SLOT="0"

IUSE="debug lto qt5 +qt6 test"
REQUIRED_USE="
	lto? ( !debug )
	^^ ( qt5 qt6 )
"

RESTRICT="!test? ( test )"

DEPEND="
	qt5? (
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtnetworkauth:5
		dev-qt/qttest:5
		dev-qt/qtwidgets:5
		dev-qt/qtxml:5
	)
	qt6? (
		dev-qt/qtbase:6[concurrent,gui,network,widgets,xml(+)]
		dev-qt/qt5compat:6
		dev-qt/qtnetworkauth:6
	)
	dev-libs/quazip:=[qt5?,qt6?]
	app-text/cmark
	sys-libs/zlib
"

RDEPEND="
	${DEPEND}
	qt5? ( dev-qt/qtsvg:5 )
	qt6? ( dev-qt/qtsvg:6 )
	>=virtual/jre-1.8.0:*
	virtual/opengl
"

BDEPEND="
	>=virtual/jdk-1.8.0:*
	media-libs/libglvnd
	app-text/scdoc
	kde-frameworks/extra-cmake-modules
	virtual/pkgconfig
	dev-cpp/tomlplusplus
	app-text/cmark
"

PATCHES=(
	"${FILESDIR}/${PN}-9.2.2-java.patch"
	"${FILESDIR}/${PN}-9.2.2-gulrak-filesystem.patch"
	"${FILESDIR}/${PN}-9.2.2-tomlplusplus.patch"
	"${FILESDIR}/${PN}-9.2.2-loud.patch"
)

src_unpack() {
	default
	rmdir "${S}/libraries/libnbtplusplus"
	mv "${WORKDIR}/libnbtplusplus-${NBTPLUSPLUS_COMMIT}" "${S}/libraries/libnbtplusplus"
}

src_prepare() {
	cmake_src_prepare
	sed -i -e 's/-Werror//' CMakeLists.txt || die 'Failed to remove -Werror via sed'
	sed -i -e "/CMAKE_CXX_FLAGS_RELEASE/d" CMakeLists.txt || die 'Failed to remove "CMAKE_CXX_FLAGS_RELEASE" from CMakeLists via sed'
}

src_configure(){
	local mycmakeargs=(
		-DLauncher_APP_BINARY_NAME="${PN}"
		-DLauncher_BUILD_PLATFORM="Gentoo"
		-DLauncher_QT_VERSION_MAJOR=$(usex qt6 6 5)
		-DENABLE_LTO=$(usex lto)
		-DBUILD_TESTING=$(usex test)
	)

	cmake_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst

	# Original issue: https://github.com/PolyMC/PolyMC/issues/227
	optfeature "old Minecraft (<= 1.12.2) support" x11-apps/xrandr
	optfeature "built-in MangoHud support" games-util/mangohud
	optfeature "built-in Feral Gamemode support" games-util/gamemode
}
