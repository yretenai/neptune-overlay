# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit ffmpeg-compat cmake git-r3

DESCRIPTION="Common components shared between Olive libraries"
HOMEPAGE="
	https://olivevideoeditor.org/
	https://github.com/olive-editor/core/
"
LICENSE="GPL-3"
SLOT="0"

EGIT_REPO_URI="https://github.com/olive-editor/core.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~arm64"
fi

IUSE="test"
RESTRICT="
	!test? ( test )
"

DEPEND="
	dev-libs/imath
	media-libs/opentimelineio
	media-video/ffmpeg-compat:6=
	virtual/opengl
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DOLIVECORE_BUILD_TESTS=$(usex test)
	)

	ffmpeg_compat_setup 6
	ffmpeg_compat_add_flags
	mycmakeargs+=( -DFFMPEG_ROOT="${SYSROOT}$(ffmpeg_compat_get_prefix 6)" )

	cmake_src_configure
}
