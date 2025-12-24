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
LICENSE="Apache-2.0 BSD BSD-2 GPL-2+ GPL-3 ISC LGPL-2.1+ LGPL-3+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE="debug lto test"
REQUIRED_USE="
	lto? ( !debug )
"

RESTRICT="!test? ( test )"

DEPEND="
	dev-qt/qtbase:6[concurrent,gui,network,widgets,xml(+)]
	dev-qt/qt5compat:6
	dev-qt/qtnetworkauth:6
	>=dev-libs/quazip-1.5
	app-text/cmark
	virtual/zlib
	x11-apps/xrandr
"

RDEPEND="
	${DEPEND}
	dev-qt/qtsvg:6
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
	"${FILESDIR}/${PN}-9.2.2-mcpack.patch"
	"${FILESDIR}/${PN}-9.2.2-gamemode.patch"
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
		-DLauncher_QT_VERSION_MAJOR=6
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
}
