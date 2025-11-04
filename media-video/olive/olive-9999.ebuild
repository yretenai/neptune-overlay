# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit ffmpeg-compat cmake git-r3 xdg

DESCRIPTION="Professional open-source non-linear video editor"
HOMEPAGE="
	https://olivevideoeditor.org/
	https://github.com/olive-editor/olive/
"
LICENSE="GPL-3"
SLOT="0"

EGIT_REPO_URI="https://github.com/olive-editor/olive.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~arm64"
fi

IUSE="test doc"
RESTRICT="
	!test? ( test )
"

DEPEND="
	media-libs/olivecore:=
	dev-qt/qtbase:6[concurrent,gui,opengl,widgets,-gles2-only]
	dev-qt/qtsvg:6
	media-libs/opencolorio:=
	media-libs/openexr:=
	media-libs/openimageio:=
	media-libs/opentimelineio:=
	media-libs/portaudio
	media-video/ffmpeg-compat:6=
	virtual/opengl
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-qt/qttools:6[linguist]
	doc? ( app-text/doxygen[dot] )
"

PATCHES=(
	"${FILESDIR}/9999-fix-opencolorio-2.3.patch"
	"${FILESDIR}/9999-fix-openimageio-3.0.patch"
	"${FILESDIR}/9999-fix-qtstring.patch"
)

src_prepare() {
	eapply_user

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_QT6="ON"
		-DBUILD_DOXYGEN="$(usex doc)"
		-DBUILD_TESTS="$(usex test)"
	)

	ffmpeg_compat_setup 6
	ffmpeg_compat_add_flags
	mycmakeargs+=( -DFFMPEG_ROOT="${SYSROOT}$(ffmpeg_compat_get_prefix 6)" )

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
