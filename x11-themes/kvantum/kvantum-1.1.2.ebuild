# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg multibuild git-r3

DESCRIPTION="SVG-based theme engine for Qt5, KDE Plasma and LXQt"
HOMEPAGE="https://github.com/tsujan/Kvantum"
EGIT_REPO_URI="https://github.com/tsujan/Kvantum.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="V${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"
IUSE="qt6"

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5=
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	kde-frameworks/kwindowsystem:5
	x11-libs/libX11
	x11-libs/libXext
	qt6? (
		dev-qt/qtbase:6[gui,widgets]
		dev-qt/qtsvg:6
	)
"
RDEPEND="${DEPEND}"
BDEPEND="dev-qt/linguist-tools:5"

pkg_setup() {
	MULTIBUILD_VARIANTS=( qt5 $(usev qt6) )
}

src_configure() {
	my_src_configure() {
		local mycmakeargs=( )
		if [[ ${MULTIBUILD_VARIANT} == qt5 ]]; then
			mycmakeargs+=( -DENABLE_QT5=ON )
		else
			mycmakeargs+=( -DENABLE_QT5=OFF -DWITHOUT_KF=ON )
		fi

		cmake_src_configure
	}
	multibuild_foreach_variant my_src_configure
}

src_compile() {
	multibuild_foreach_variant cmake_src_compile
}

src_install() {
	multibuild_foreach_variant cmake_src_install
}
