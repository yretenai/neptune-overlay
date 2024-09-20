# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Common components shared between Olive libraries"
HOMEPAGE="
	https://olivevideoeditor.org/
	https://github.com/olive-editor/core/
"
EGIT_REPO_URI="https://github.com/olive-editor/core.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"

IUSE="test"
RESTRICT="
	!test? ( test )
"

DEPEND="
	dev-libs/imath
	media-libs/opentimelineio
	>=media-video/ffmpeg-3.0:=
	virtual/opengl
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DOLIVECORE_BUILD_TESTS=$(usex test)
	)

	cmake_src_configure
}
