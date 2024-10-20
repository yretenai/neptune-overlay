# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

EGIT_SUBMODULES=( )

DESCRIPTION="Lightweight library for managing graphics and abstracting video input"
HOMEPAGE="https://github.com/stevenlovegrove/Pangolin"
EGIT_REPO_URI="https://github.com/stevenlovegrove/Pangolin.git"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~ppc64 ~x86"
fi

LICENSE="MIT"
SLOT="0"

IUSE="wayland X"

DEPEND="
	media-libs/mesa[egl(+)]
	dev-cpp/eigen:3
	media-libs/glew
	media-libs/libjpeg-turbo
	media-libs/libpng
	media-libs/openexr
	media-video/ffmpeg
	media-libs/libdc1394
	sys-libs/libraw1394
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
		dev-util/wayland-scanner
	)
	X? (
		x11-libs/libxkbcommon
	)
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_EXAMPLES=OFF
		-DBUILD_TOOLS=OFF
		-DBUILD_PANGOLIN_PYTHON=OFF
	)

	cmake_src_configure
}
