# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 xdg

DESCRIPTION="Professional open-source non-linear video editor"
HOMEPAGE="
	https://olivevideoeditor.org/
	https://github.com/olive-editor/olive/
"
EGIT_REPO_URI="https://github.com/olive-editor/olive.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"

IUSE="test qt5 qt6 doc"
RESTRICT="
	!test? ( test )
"
REQUIRED_USE="
	|| ( qt5 qt6 )
"

DEPEND="
	media-libs/olivecore:=
	qt5? (
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		dev-qt/qtsvg:5
		dev-qt/qtwidgets:5
	)
	qt6? (
		dev-qt/qtbase:6[concurrent,gui,opengl,widgets,-gles2-only]
		dev-qt/qtsvg:6
	)
	media-libs/opencolorio:=
	media-libs/openexr:=
	media-libs/openimageio:=
	media-libs/opentimelineio:=
	media-libs/portaudio
	media-video/ffmpeg
	virtual/opengl
"
RDEPEND="${DEPEND}"
BDEPEND="
	qt5? (
		dev-qt/linguist-tools:5
	)
	qt6? (
		dev-qt/qttools:6[linguist]
	)
	doc? ( app-text/doxygen[dot] )
"

PATCHES=(
	"${FILESDIR}/fix-opencolorio-2.3.patch"
)

src_prepare() {
	eapply_user

	if use qt6; then
		eapply "${FILESDIR}/fix-qtstring.patch"
	fi

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_QT6="$(usex qt6)"
		-DBUILD_DOXYGEN="$(usex doc)"
		-DBUILD_TESTS="$(usex test)"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	if use doc; then
		docinto html
		dodoc -r "${BUILD_DIR}"/docs/html/*
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
