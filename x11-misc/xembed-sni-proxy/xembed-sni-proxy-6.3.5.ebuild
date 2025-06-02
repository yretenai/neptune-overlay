# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KDE_ORG_NAME="plasma-workspace"
KFMIN=6.13.0
QTMIN=6.8.0
inherit cmake plasma.kde.org

DESCRIPTION="Legacy xembed tray icons support for SNI-only system trays"
HOMEPAGE="https://invent.kde.org/plasma/plasma-workspace/-/blob/master/xembed-sni-proxy/Readme.md"
CMAKE_USE_DIR="${S}/${PN}"

LICENSE="GPL-2"
SLOT="6/${PV}"
KEYWORDS="~amd64"

DEPEND="
	>=dev-qt/qtbase-${QTMIN}:6[dbus]
	>=kde-frameworks/kcoreaddons-${KFMIN}:6
	>=kde-frameworks/kdbusaddons-${KFMIN}:6
	>=kde-frameworks/kwindowsystem-${KFMIN}:6
	>=kde-frameworks/kcrash-${KFMIN}:6
	x11-misc/xcb
	x11-libs/libXtst
	x11-libs/xcb-util-image
	!!kde-plasma/plasma-workspace
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=kde-frameworks/extra-cmake-modules-${KFMIN}:0
"

PATCHES=( "${FILESDIR}/${PN}-6.3.5-standalone.patch" )

src_prepare() {
	cmake_src_prepare

	sed -e "/set/s/GENTOO_PV/$(ver_cut 1-3)/" \
		-i ${PN}/CMakeLists.txt || die "Failed to prepare CMakeLists.txt"
}
